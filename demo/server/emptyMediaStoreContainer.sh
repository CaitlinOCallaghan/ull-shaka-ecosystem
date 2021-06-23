#!/bin/bash

# WARNING: This script will completely empty your MediaStore container!

CONTAINER_NAME='shaka_ull'

VENV='./env'
if test -d "$VENV"; then
    echo "Virtual environment already exists."
else 
    echo "Creating and setting up virtual environment ${VENV}."
    python3 -m venv env
    source ${VENV}/bin/activate
    pip install boto3
    deactivate
fi

echo "Activating ${VENV}"
source ${VENV}/bin/activate

echo "Let the purge commence"

python3 purge_mediastore_container.py ${CONTAINER_NAME} /

echo "Purge complete!"

echo "Deactivating virtual environment"
deactivate