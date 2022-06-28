#!/bin/bash
#
# Copyright 2021 DeepMind Technologies Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Downloads and unzips the Uniclust30 database for AlphaFold.
#
# Usage: bash download_uniclust30.sh /path/to/download/directory
set -e

if [[ $# -eq 0 ]]; then
    echo "Error: download directory must be provided as an input argument."
    exit 1
fi

if ! command -v aria2c &> /dev/null ; then
    echo "Error: aria2c could not be found. Please install aria2c (sudo apt install aria2)."
    exit 1
fi

DOWNLOAD_DIR="$1"
ROOT_DIR="${DOWNLOAD_DIR}/uniclust30"
# Mirror of:
# http://wwwuser.gwdg.de/~compbiol/uniclust/2018_08/uniclust30_2018_08_hhsuite.tar.gz
SOURCE_URL="https://storage.googleapis.com/alphafold-databases/casp14_versions/uniclust30_2018_08_hhsuite.tar.gz"
BASENAME=$(basename "${SOURCE_URL}")

if [ -d "${ROOT_DIR}" ]; then
    echo "WARNING: Destination directory '${ROOT_DIR}' does already exist."
    read -p "Proceed by deleting existing download directory? [Y/n]" -n1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "INFO: Deleting previous download directory: '${ROOT_DIR}'"
        rm -rf "${ROOT_DIR}"
    else
        echo "Aborting download."
        exit 0
    fi
fi

mkdir --parents "${ROOT_DIR}"
aria2c "${SOURCE_URL}" --dir="${ROOT_DIR}"

if ! command -v pigz &> /dev/null
then
    tar --extract --verbose --file="${ROOT_DIR}/${BASENAME}" \
        --directory="${ROOT_DIR}"
else
    tar -I pigz --extract --verbose --file="${ROOT_DIR}/${BASENAME}" \
        --directory="${ROOT_DIR}"
fi

# The extracted files are only user-readable. On a multi-user system this
# is problematic, therefore:
find "${ROOT_DIR}" -type f exec chmod 444 {} \;

rm "${ROOT_DIR}/${BASENAME}"
