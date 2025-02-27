#!/bin/sh



Help()
{
   # Display Help
   echo "This script processes a tsv file with the metadata for submission to the ENA, registers a RNA-seq virtual sample if necessary and produces xml files to submit your data."
   echo
   echo "Syntax: submit_metadata.sh [-t arg|c arg|m arg|p arg|l arg|h]"
   echo "options:"
   echo "-t     Input tsv file."
   echo "-c     Config yaml file with your ENA WEBIN username and password."
   echo "-m     Mode (validate or submit). Default: validate"
   echo "-a     Data project accession number, if already registered"
   echo "-p     Project name (eg. ERGA-BGE, CBP, EASI, ERGA-pilot, other). Default: ERGA-BGE"
   echo "-l     HiC library construction protocol. Default: Omni-C"
   echo "-h     Print this Help."
   echo
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
OPTS=":t:c:m:a:p:l:h"
while getopts ${OPTS} option; do
   case $option in
      t)
         IN=$OPTARG
         ;;
      c)
         CONFIG=`cat $OPTARG`
         ;;
      m)
         MODE=$OPTARG
         ;;
      a)
         ACCESSION=$OPTARG
         ;;
      p)
         PROJECT=$OPTARG
         ;;
      l) 
         HIC_LIBRARY=$OPTARG
         ;;
      \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
      :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
      h) # display Help
         Help
         exit;;
   esac
done

# shift "$(( OPTIND - 1 ))"
if [ -z "$IN" ] ; then
        echo 'Missing -t'
        Help
        exit 1
elif [ -z "$CONFIG" ]; then
        echo 'Missing -c'
        Help 
        exit 1
elif [ -z "$MODE" ]; then
        MODE="validate"
elif [ -z "$HIC_LIBRARY" ]; then
        HIC_LIBRARY="Omni-C"
fi
FIFS=$IFS

header=($(head -n 1 $IN))
for i in "${!header[@]}"; do
    if [ "${header[$i]}" = 'biosample_accession' ]; then
        biosample_i="$i"
    fi
    if [ "${header[$i]}" = 'tolid' ]; then
        tolid_i="$i"
    fi
    if [ "${header[$i]}" = 'library_strategy' ]; then
        strategy_i="$i"
    fi
    if [ "${header[$i]}" = 'exp_attr' ]; then
        exp_i="$i"
    fi
done

IFS=$'\n'
declare -A biosamples
for line in `cat $IN`; do
    IFS=$'\t'
    tmp=($line);
    tolid=${tmp[$tolid_i]};
    
    if [[ ${tmp[$biosample_i]} =~ "," ]]; then
        if [[ ${biosamples[${tmp[$strategy_i]}]} ]]; then
                biosamples[${tmp[$strategy_i]}]+=","
        fi
        biosamples[${tmp[$strategy_i]}]+=${tmp[$biosample_i]};
    fi
done

IFS=$','
for type in ${!biosamples[@]}; do
    declare -A lists
    for s in ${biosamples[$type]}; do
        if ! [[ ${lists[$type]} =~ $s ]]; then
            lists[$type]+="$s "
        fi
    done
done

IFS=$'\n'
for line in $CONFIG; do
    if [[ $line =~ username ]]; then
        IFS=$' '
        username=($line)
    fi
    if [[ $line =~ password ]]; then
        IFS=$' '
        password=($line)
    fi
done

if [[ -n ${!lists[@]} ]]; then 

    >&2 echo "Requesting TOKEN to the ENA."
    TOKEN=$(curl -X POST "https://www.ebi.ac.uk/ena/submit/webin/auth/token" -H "accept: */*" -H  "Content-Type: application/json" -d "{\"authRealms\":[\"ENA\"],\"password\":\"${password[1]}\",\"username\":\"${username[1]}\"}")
    declare -A vsample

    for list in ${!lists[@]}; do 
        >&2 echo "Running command: python3 $SCRIPT_DIR/virtual_samples/virtual_sample.py  -s ${lists[$list]} -t $TOKEN -m $MODE";
        vsample[$list]=$(python3 $SCRIPT_DIR/virtual_samples/virtual_sample.py  -s ${lists[$list]}  -t $TOKEN -m $MODE);
        vsample[$list]=$(echo ${vsample[$list]}|tr -d '\n\t\r ')
        # echo ${vsample[$list]}
        # echo $list
    done
fi

IFS=$'\n'
OXML="$(basename $IN '.tsv')"".4subm.tsv"
dd if=/dev/null of=$OXML count=0

for line in `cat $IN`; do
    IFS=$'\t'
    tmp=($line);
    if [[ ${biosamples[${tmp[$strategy_i]}]} ]]; then
        tmp[$biosample_i]=${vsample[${tmp[$strategy_i]}]}
    fi
    if [[ ${tmp[$strategy_i]} == "Hi-C" ]]; then
        tmp[$exp_i]="LIBRARY_CONSTRUCTION_PROTOCOL: $HIC_LIBRARY"
    fi
    printf "${tmp[*]}\n" >> $OXML
        # else
            # printf "$line\n" >> $OXML
done
# else
#     OXML=$IN;

if [ -z "$ACCESSION" ]; then
    if [ -z "$PROJECT" ]; then
        >&2 echo "Running command: $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid";
        $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid     
    else
        >&2 echo "Running command: $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid -p $PROJECT";
        $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid -p $PROJECT
    fi
else
    >&2 echo "Running command: $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid -a $ACCESSION -x experiment runs";
    $SCRIPT_DIR/get_ENA_xml_files.py -f $OXML -o $tolid -a $ACCESSION -x experiment runs  
fi

IFS=$FIFS