*DATA submission strategy for read data projects part of the ERGA-BGE*

Deposition of the sequencing data in the ENA is the responsibility of 
each sequencing center contributing to the BGE ERGA Stream. In this
document, we will describe the submission process and the structure that
the projects should have.

1.  Create the data project

Two options for data submission are available: the first is via the Webin-CLI
(<https://github.com/enasequence/webin-cli/blob/master/README.md>) and the 
second method is via the web interface, which we will describe here.

First, access the Webin interface with your ENA/EGA user credentials
(<https://www.ebi.ac.uk/ena/submit/webin/login>). Please, register if
you do not have an account yet.

Once you are logged in into the system you can register the data and
analysis projects by clicking “Register Study (project)” on the
Dashboard. Description on how to fill all the fields for ERGA-BGE 
projects is given below, please, go to
<https://ena-docs.readthedocs.io/en/latest/submit/study.html> for
general details on how to register a project.

The **release date** indicates when the study and all its data will be
made public. When first registering a project, it can be as much as 2
years beyond the present date but you should change it to be released 
immediately. 

<u>Data Project registration</u>

-   **Alias:** erga-bge-***tolid_prefix***-study-rawdata-***date***
-   **Study Name:** ***tolid_prefix*** 
-   **Study Title:** ***species_name***, genomic and transcriptomic data
-   **Detailed study abstract:** This project collects the genomic and transcriptomic data generated for ***species_name*** to facilitate genome assembly and annotation as part of the Biodiversity Genomics Europe project (BGE, https://biodiversitygenomics.eu/) and organised by the European Reference Genome Atlas (ERGA, https://www.erga-biodiversity.eu/) initiative.
-   **Add Study attributes:** Click “+” and add the tag “keyword” and the value “ERGA-BGE”. Then click Add.

Now you can submit the project. A new window will show up with the
assigned project ID, that you can also check in the “Studies Report” tab
of the Dashboard. 

2.  Read submission

After registering the study, you can submit the reads
referring to them. Note that samples and studies will only be associated
after experiments have been submitted. Raw read submissions can be
performed either interactively, programmatically or via webin-cli. 
Details on how to carry out read submission in any of these 3 ways can
be found at:
<https://ena-docs.readthedocs.io/en/latest/submit/reads.html>. We recommend
doing it programatically so that consistency is maintained. For ONT fast5 
data, this way is also recommended, as the webin-cli cannot be used. 

For the experiment submission, you will need the study and sample references.
The biosample accession number for the sequenced sample can be looked up in 
the tracking tool usin the tube_or_well_id. The study name or accession number 
will be set or obtained in step 1 above.


