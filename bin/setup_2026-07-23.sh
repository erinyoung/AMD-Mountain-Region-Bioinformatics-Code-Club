#!/bin/bash

shopt -s expand_aliases

echo "Downloading Docker image"
docker pull staphb/kraken2:2.17.1
docker pull staphb/krakentools:1.2.1
docker pull staphb/multiqc:1.35

echo "Creating aliases"
alias kraken2='docker run --rm -v "$(pwd):/data" -w /data staphb/kraken2:2.17.1 kraken2'
alias combine_kreports='docker run --rm -v "$(pwd):/data" -w /data staphb/krakentools:1.2.1 combine_kreports.py'
alias multiqc='docker run --rm -v "$(pwd):/data" -w /data staphb/multiqc:1.35 multiqc'

echo "Downloading test FASTQ files"
# Downloading Read 1, also known as the "Forward" Read
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR359/080/SRR35981380/SRR35981380_1.fastq.gz

# Downloading Read 2, also known as the "Reverse" Read
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR359/080/SRR35981380/SRR35981380_2.fastq.gz


echo "Downloading standard database"
mkdir -p standard_8gb
cd standard_8gb

# Download the pre-built 8GB database archive (took 3-3.5 minutes when preparing these materials)
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20260626.tar.gz

# Extract the archive (took an additional ~5 minutes)
tar -xvzf k2_standard_08_GB_20260626.tar.gz

# Clean up the compressed file to save disk space
rm k2_standard_08_GB_20260626.tar.gz
cd ..

echo "Downloading viral Database"
mkdir -p viral
cd viral

# Download the pre-built viral database archive
wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20260626.tar.gz

# Extract the archive
tar -xvzf k2_viral_20260626.tar.gz

# Clean up the compressed file
rm k2_viral_20260626.tar.gz
cd ../