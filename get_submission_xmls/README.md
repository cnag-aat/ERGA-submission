**README**

The scripts get_ENA_xml_files.py and get_umbrella_xml.py work with python3, the only additional requirements are the modules JINJA2 and pandas. 

The script ***submit_metadata.sh*** takes the metadata tabular file and parses it in order to: 

1. Create any necessary virtual samples (if you run the script with the "-m submit" option, it will take care of the submission of the virtual sample to BioSamples).
2. Update the input metadata tabular file to refer to the virtual samples that were just created (when necessary) and to add the "Library construction protocol" to the HiC lines (default is OmniC, please change it with -l option if necessary).
3. Run the get_ENA_xml_files.py script to produce the xml files. 

It takes as input a config file in yaml format with your ENA Webin credentials (see templates/config.yaml).


**Submit your project**

If you plan to submit your data using these scripts, you would need to complete the following steps. 
1. Get a tabular file with the metadata of your runs (see examples/ directory to get an idea of how to make your runs table).
2. Transfer all the reads to your account space in the ENA (see ``https://ena-docs.readthedocs.io/en/latest/submit/fileprep/upload.html`` for more info)
3. Run the submit_metadata.sh script found in this repository
4. Submit the obtained xml files (eg using curl: ``curl -u Webin-XXXX:psswd -F "SUBMISSION=@submission.xml" -F "PROJECT=@study.xml" -F "EXPERIMENT=@exp.xml" -F "RUN=@runs.xml" https://www.ebi.ac.uk/ena/submit/drop-box/submit/``)
5. Run the get_umbrella_xml_ENA.py script found in this repository
6. Submit the obtained xml file (eg using curl: ``curl -u Webin-XXXX:psswd -F "SUBMISSION=@submission.xml" -F "PROJECT=@umbrella.xml"  https://www.ebi.ac.uk/ena/submit/drop-box/submit/``)

**USAGE**

```
 bash get_submission_xmls/submit_metadata.sh -h

This script processes a tsv file with the metadata for submission to the ENA, registers a RNA-seq virtual sample if necessary and produces xml files to submit your data.

Syntax: submit_metadata.sh [-t arg|c arg|m arg|p arg|l arg|h]
options:
-t     Input tsv file.
-c     Config yaml file with your ENA WEBIN username and password.
-m     Mode (validate or submit). Default: validate
-a     Data project accession number, if already registered
-p     Project name (eg. ERGA-BGE, CBP, EASI, ERGA-pilot, other). Default: ERGA-BGE
-l     HiC library construction protocol. Default: Omni-C
-h     Print this Help.
```



```
    ./get_submission_xmls

usage: get_ENA_xml_files.py [-h] -f FILES
                            [-p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}]
                            [-x {all,study,experiment,runs} [{all,study,experiment,runs} ...]]
                            -o OUT_PREFIX [-a ACCESSION]

options:
  -h, --help            show this help message and exit
  -f FILES, --files FILES
                        TABLE file with appropriate headers
  -p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}, --project {ERGA-BGE,CBP,ERGA-pilot,EASI,other}
                        project
  -x {all,study,experiment,runs} [{all,study,experiment,runs} ...], --xml {all,study,experiment,runs} [{all,study,experiment,runs} ...]
                        specify which xml files do you want
  -o OUT_PREFIX, --out_prefix OUT_PREFIX
                        prefix to add to output files
  -a ACCESSION, --accession ACCESSION

```


```
./get_submission_xmls/get_umbrella_xml_ENA.py -h

usage: get_umbrella_xml_ENA.py [-h] [-p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}]
                               [-c CENTER] [-n NAME]
                               [--sample-ambassador SAMPLE_AMBASSADOR] -t
                               TOLID -s SPECIES -x TAXON_ID -a
                               CHILDREN_ACCESSIONS [CHILDREN_ACCESSIONS ...]

options:
  -h, --help            show this help message and exit
  -p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}, --project {ERGA-BGE,CBP,ERGA-pilot,EASI,other}
                        project
  -c CENTER, --center CENTER
                        center name
  -n NAME, --name NAME  common name
  --sample-ambassador SAMPLE_AMBASSADOR
                        Sample ambassador for ERGA-pilot projects
  -t TOLID, --tolid TOLID
                        tolid
  -s SPECIES, --species SPECIES
                        species scientific name
  -x TAXON_ID, --taxon_id TAXON_ID
                        species taxon_id
  -a CHILDREN_ACCESSIONS [CHILDREN_ACCESSIONS ...], --children_accessions CHILDREN_ACCESSIONS [CHILDREN_ACCESSIONS ...]
                        species scientific name
```

**EXAMPLES**

- Leiobunum_subalpinum, ERGA-BGE:
``  bash submit_metadata.sh -t examples/qqLeiSuba.BGE.runs.tsv  -c config.yaml -m validate -p ERGA-BGE -l Omni-C ``



**UMBRELLA**

For BGE projects, the umbrella can be created by the administrators of the BGE ENA account or by the person submitting the data. The script to create umbrella projects is provided, but please, only use it if you want to be responsible to add all the children projects. If you would prefer not to be in charge of that, we are happy to take care of it. 

- Example: ~/bin/get_umbrella_xml_ENA.py -s "Phakellia ventilabrum" -t odPhaVent2 -n "the chalice sponge"  -p ERGA-pilot -a PRJEB70435 PRJEB70436 -x 942649 --sample-ambassador "Ana Riesgo (Spain)"


