import csv
import argparse
import requests
import json
import sys
import configparser
import os

from argparse import ArgumentParser
from datetime import datetime

parser = ArgumentParser()
biosample = ''
parser.add_argument("-s", "--sample", dest="biosample", nargs = "+", 
                    help="fetch biosample accession from the ENA", metavar="BIOSAMPLE")

parser.add_argument("-t", "--mytoken", dest="mytoken",
                     help= "your ENA WEBIN AUTHENTICATION TOKEN", metavar="TOKEN")

parser.add_argument("-m", "--mode", dest="mode", choices=['submit', 'validate'], default = "validate",
                     help= "choose if you want to run only json validation or to go ahead with the submission", metavar="MODE")

args = parser.parse_args()

if not args.biosample:
    exit("No input biosample id has been given, nothing to do.")

if not args.mytoken:
    exit("ENA WEBIN AUTHENTICATION TOKEN missing, please provide it.")

path = "https://www.ebi.ac.uk/biosamples/"
validate_path = "https://www.ebi.ac.uk/biosamples/validate/"
date = datetime.now().strftime('%Y-%m-%dT%H:%M:%S')

x = []
for id in args.biosample:
    x.append(requests.get(path + "sample/" + id).json())
    sys.stderr.write(path + id + "\n")
sys.stderr.write(str(x) + "\n")

out = {}
out['name'] = ""
out['release'] = date
out['characteristics'] = {}
new= ["ENA-CHECKLIST", "alias", "title", "description", "composed of", "organism part"]
for i in new:
  out['characteristics'][i] = []

for item in x[0]["characteristics"].keys():     
    if item == "SRA accession" or item == "organism part" or item == "Submitter Id":
      print ()
    elif not "1" in x or x[1]["characteristics"][item] == x[0]["characteristics"][item]:
      out['characteristics'][item] = x[0]["characteristics"][item]
      if item == "tolid":
        tolid = x[0]["characteristics"][item][0]["text"]
      if item == "broker name":
        out['characteristics'][item] = []
        out['characteristics'][item].append({"text": 'CNAG', "tag": "attribute"})

parts = []
for i in x:
  if not i["characteristics"]["organism part"][0]["text"] in parts:
    parts.append(i["characteristics"]["organism part"][0]["text"])

sys.stderr.write(tolid + "\n")
out['name'] = tolid + "_RNAp"

out['characteristics']["alias"].append({"text": tolid + "_RNA_pool", "tag": "attribute"})
out['characteristics']["title"].append({"text": tolid + " RNA pool", "tag": "attribute" }) 
out['characteristics']["description"].append({"text": "This sample is a RNA pool of multiple samples." +\
                     " It is composed of samples " + ", ".join(args.biosample), 
                     "tag": "attribute"})
out['characteristics']["composed of"].append({"text": ", ".join(args.biosample), "tag": "attribute"})
out['characteristics']["organism part"].append({"text": ", ".join(parts), "tag": "attribute"})

jout = json.dumps(out)

headers =  {"Content-Type": "application/json", "Authorization":"Bearer " + args.mytoken,
            "Content-Length":"440", "Host": "www.ebi.uk"}

# args.mode = "validate"
if args.mode == "submit":
    sys.stderr.write("Submitting virtual sample with json as follows:\n")
    sys.stderr.write(jout + "\n")
    response = requests.post(path + "samples", data=jout, headers=headers)
    sys.stderr.write(str(response.json()) + "\n")
    if response.status_code == 201:
      sys.stderr.write("Virtual sample " + tolid + "_RNAp has been submitted with accession biosample id: ")
      submitted = response.json()
      sys.stderr.write(submitted['accession'] + "\n")
      print(submitted['accession'])
    else:
      sys.stderr.write("Virtual sample not correctly validated, an error has occurred. API response code: " + str(response.status_code) + "\n")
else:
    sys.stderr.write("Validatting virtual sample with json as follows:\n")
    response = requests.post(validate_path, data=jout, headers=headers)
    sys.stderr.write(str(response.json()) + "\n")
    if response.status_code == 200:
        sys.stderr.write ("Virtual sample has been correctly validated. You can now proceed with the submission. API response code: " + str(response.status_code) + "\n")
        # print(x[0]['accession'])
    else:
        sys.stderr.write("Virtual sample not correctly validated, an error has occurred. API response code: " + str(response.status_code) + "\n")