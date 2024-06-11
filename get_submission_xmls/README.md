**README**

The scripts get_ENA_xml_files.py and get_umbrella_xml.py work with python3, the only additional requirements are the modules JINJA2 and pandas. 

**USAGE**

```
    usage: get_ENA_xml_files.py [-h] -f FILES [-p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}]
                            [-x {all,study,experiment,runs} [{all,study,experiment,runs} ...]] -o OUT_PREFIX


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
```


```
   ./get_umbrella_xml_ENA.py -h

usage: get_umbrella_xml_ENA.py [-h] [-p {ERGA-BGE,CBP,ERGA-pilot,EASI,other}] [-c CENTER] [-n NAME]
                               [--sample-ambassador SAMPLE_AMBASSADOR] -t TOLID -s SPECIES -x TAXON_ID -a CHILDREN_ACCESSIONS
                               [CHILDREN_ACCESSIONS ...]

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

- Phakellia, ERGA-pilot:
`` get_ENA_xml_files.py -f examples/sponge.pilot.runs.tsv -p ERGA-pilot -o odPhaVent``

- Valencia hispanica, ERGA-BGE:
``  get_ENA_xml_files.py -f examples/fValHis.BGE.runs.tsv -p ERGA-BGE -o fValHis1 ``

**UMBRELLA**

For BGE projects, the umbrella can be created by the administrators of the BGE ENA account or by the person submitting the data. The script to create umbrella projects is provided, but please, only use it if you want to be responsible to add all the children projects. If you would prefer not to be in charge of that, we are happy to take care of it. 

- Example: ~/bin/get_umbrella_xml_ENA.py -s "Phakellia ventilabrum" -t odPhaVent2 -n "the chalice sponge"  -p ERGA-pilot -a PRJEB70435 PRJEB70436 -x 942649 --sample-ambassador "Ana Riesgo (Spain)"


