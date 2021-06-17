#!/usr/bin/python
## ---------------------------------------------------------------------------
## AWS Elemental Technologies Inc. Company Confidential Strictly Private
##
## ---------------------------------------------------------------------------
## COPYRIGHT NOTICE
## ---------------------------------------------------------------------------
## Copyright 2017 (c) AWS Elemental Technologies Inc.
##
## AWS Elemental Technologies owns the sole copyright to this software. Under
## international copyright laws you (1) may not make a copy of this software
## except for the purposes of maintaining a single archive copy, (2) may not
## derive works herefrom, (3) may not distribute this work to others. These
## rights are provided for information clarification, other restrictions of
## rights may apply as well.
##
## This is an unpublished work.
## ---------------------------------------------------------------------------
## WARRANTY
## ---------------------------------------------------------------------------
## AWS Elemental Technologies Inc. MAKES NO WARRANTY OF ANY KIND WITH REGARD TO
## THE USE OF THIS SOFTWARE, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
## PARTICULAR PURPOSE.
## ---------------------------------------------------------------------------


import boto3
import sys
from pprint import pprint

filesToDelete = []
foldersToRecurse = []

def usage():

  print("%s [ContainerName] [Path]/" % sys.argv[0])
  print("Example: %s TestContainerPleaseIgnore PathToDelete/" % sys.argv[0])

def delete_things():
  print("%s files to delete." % len(filesToDelete))
  while len(filesToDelete) > 0:
    thisFile = filesToDelete.pop()
    print("=== DELETE:  %s ===" % thisFile)
    try:
      delete_response = object_client.delete_object(Path="%s" % (thisFile))
    except KeyboardInterrupt:
      break
      sys.exit
    except:
      print("W: trouble deleting %s" % file)

def list_items(path, next_token):

  print("Gathering list of files in %s..." % path)

  if(next_token == ""):
    listResponse = object_client.list_items(Path=path, MaxResults=50)
    print("I: REQID: %s" % listResponse['ResponseMetadata']['RequestId'])
    for item in listResponse['Items']:
      if(item['Type'] == "FOLDER"):
        if(path == "/"):
          newPath = "/%s/" % item['Name']
        else:
          newPath = "%s%s/" % (path, item['Name'])
        foldersToRecurse.append(newPath)
        print("Adding folder: %s" % newPath)
      else:
        filesToDelete.append("%s%s" % (path, item['Name']))
        print("Found file: %s%s" % (path, item['Name']))
    delete_things()

    try:
      while(listResponse['NextToken'] != ""):
        print("I: NextToken: %s" % listResponse['NextToken'])
        nt = listResponse['NextToken']
        listResponse = object_client.list_items(Path=path, MaxResults=50, NextToken=nt)
        for item in listResponse['Items']:
          if(item['Type'] == "FOLDER"):
            if(path == "/"):
              newPath = "/%s/" % item['Name']
            else:
              newPath = "%s%s/" % (path, item['Name'])
            foldersToRecurse.append(newPath)
          else:
            filesToDelete.append("%s%s" % (path, item['Name']))
        delete_things()
    except KeyError:
      print("No nextToken found.")

def purgeContainer(container_name, path="/"):
  print("Starting at %s" % path)
  list_items(path, "")

  for subFolder in foldersToRecurse:
    list_items(subFolder, "")


if __name__ == "__main__":
  if(len(sys.argv) < 3):
    usage()
    exit()

  container_name = sys.argv[1]
  container_path = sys.argv[2]

  if(container_path.endswith('/')):

    container_client = boto3.client('mediastore')
    container_data = container_client.describe_container(ContainerName=container_name)
    containerEndpoint = container_data['Container']['Endpoint']
    object_client = boto3.client('mediastore-data', endpoint_url=containerEndpoint)

    print("Clearing container %s" % container_name)
    purgeContainer(sys.argv[1], path=sys.argv[2])

  else:
    usage()
    exit()
