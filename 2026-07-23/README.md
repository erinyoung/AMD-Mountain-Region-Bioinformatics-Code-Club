---

# Taxonomic Classification with Kraken2

## Session Overview

Welcome back to the AMD Mountain Region Bioinformatics Code Club! In this 30-minute, hands-on session, we will explore the fundamentals of taxonomic classification using Kraken2. Building on our previous explorations of bioinformatic files, we will use our Measles virus (MeV) toy datasets—both the clinical patient sample (`mev-pat-toy`) and the wastewater surveillance sample (`mev-ww-toy`)—to identify the organisms present in raw sequence reads.

By the end of this 30-minute code-along, participants will be able to:

* **Deploy containerized workflows:** Continue utilizing Docker to seamlessly run Kraken2 and KrakenTools without the need for complex local software compilation.
* **Execute k-mer based classification:** Run FASTQ files through Kraken2 to assign taxonomic labels to short DNA reads.
* **Evaluate database dependencies:** Explain why running the exact same sample against a standard 8GB database versus a targeted viral database yields fundamentally different results.

## How Kraken2 is Used in Bioinformatics

At its core, Kraken2 is a highly efficient taxonomic classification system. While aligners like Minimap2 are designed to map reads to specific coordinates on a single reference genome, Kraken2 is designed to quickly answer a broader question: *"What exactly is in this sample?"*

Instead of aligning full sequences, Kraken2 uses a "k-mer" based approach. It chops each short sequence read into even smaller, overlapping fragments of a specific length (k-mers) and searches for exact matches within a massive, pre-indexed database of known genomes. This exact-matching technique allows Kraken2 to classify millions of reads in a matter of minutes, making it a staple tool in modern public health pipelines.

### Identifying and Filtering Contamination

In a perfect world, a sequenced clinical sample would only contain the DNA or RNA of the target pathogen. In reality, biological samples are incredibly messy. One of the most critical applications of Kraken2 is quality control (QC) and contamination screening. Bioinformaticians run raw FASTQ files through Kraken2 to identify and manage unwanted genetic material:

* **Host DNA Depletion:** Clinical samples, such as nasal swabs or blood draws, inherently contain massive amounts of human DNA. Kraken2 quickly flags human reads so they can be digitally removed (depleted) prior to assembly. This not only speeds up downstream analysis but is often legally required to protect patient privacy.
* **Laboratory Contamination:** Sequencing reagents, extraction kits, and laboratory environments can introduce background microbial DNA (often referred to as the "kit-ome"). Kraken2 helps laboratories spot unexpected bacteria or fungi, ensuring that a reported pathogen is actually from the patient and not the water used in the lab.
* **Cross-Contamination:** When multiplexing (running multiple different samples on the same sequencing flow cell), "barcode leakage" can occur. Kraken2 can verify sample purity by checking if a high-concentration sample has accidentally bled into a neighboring sample.

### Wastewater Surveillance

While clinical sequencing focuses on an individual, wastewater sequencing is an environmental "metagenomic" approach that looks at an entire community. Wastewater is a complex biological soup containing human waste, agricultural runoff, and massive amounts of environmental bacteria. Kraken2 thrives in this complexity.

* **Community-Level Pathogen Tracking:** Public health laboratories use Kraken2 to scan raw wastewater reads for specific targets—like SARS-CoV-2, Measles, or Polio. Because infected individuals shed these viruses into the wastewater system before they ever seek clinical testing, Kraken2 acts as an early warning system for localized outbreaks.
* **Metagenomic Profiling:** Beyond single targets, Kraken2 can characterize the entire microbial landscape of a water sample. This allows researchers to monitor the baseline health of a watershed and detect sudden ecological shifts.
* **Signal Isolation:** Because wastewater is heavily dominated by bacterial and human DNA, finding a specific virus is like finding a needle in a haystack. Kraken2 acts as a powerful sieve, separating the viral reads from the background noise so that downstream tools can accurately assemble the pathogen's genome and identify specific circulating variants.

## The Importance of Database Selection

A critical concept in public health bioinformatics is that **your classification results are entirely dependent on the contents of your database.**

In this session, we will investigate this dependency by running our measles FASTQ files through two distinct databases:

* **The Standard 8GB Database:** A broad, size-capped database that includes a generalized mix of bacteria, archaea, and viruses. While excellent for general metagenomics, it may lack the granular depth needed for specific pathogen surveillance.
* **The Viral Database:** A highly targeted database optimized specifically for viral genomics, which typically yields higher sensitivity and more specific lineage calls for viral isolates and wastewater streams.

## Environment Setup

As in previous sessions, we will perform all tasks within our GitHub Codespaces environment using the standard Free Tier (2-core, 4GB RAM) hardware configuration. Because Kraken2 can be memory-intensive, we will pay close attention to how the 8GB database interacts with our computational limits.

## Tool Installation

We will avoid complex local software compilation by utilizing the StaPH-B Docker images for both Kraken2 and KrakenTools. We will pull the images and set up aliases, allowing us to use the commands directly as if they were installed locally.

### Pulling Kraken2 and KrakenTools

```bash
# Pull the Kraken2 and KrakenTools images from the StaPH-B repository
docker pull staphb/kraken2:2.1.3
docker pull staphb/krakentools:1.2

# Create aliases to streamline the commands
alias kraken2='docker run --rm -v "$(pwd):/data" -w /data staphb/kraken2:2.1.3 kraken2'
alias combine_kreports='docker run --rm -v "$(pwd):/data" -w /data staphb/krakentools:1.2 combine_kreports.py'

```

## Downloading Pre-Built Databases

Building a Kraken2 database from scratch requires significant computational time and memory—often far exceeding the 4GB of RAM available on our free-tier Codespace. Instead, we will download pre-built databases from the widely used Kraken 2 index archive maintained by the Langmead Lab.

### 1. The Standard 8GB Database

This is a size-capped version of the massive Standard database. It includes a broad reference library of archaea, bacteria, viruses, plasmids, and the human genome.

```bash
# Create a directory for the database
mkdir -p data/db/standard_8gb
cd data/db/standard_8gb

# Download the pre-built 8GB database archive (This will take a few minutes)
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20240904.tar.gz

# Extract the archive
tar -xvzf k2_standard_08gb_20240904.tar.gz

# Clean up the compressed file to save disk space
rm k2_standard_08gb_20240904.tar.gz
cd ../../..

```

### 2. The Viral Database

This is a much smaller, highly targeted database (around 500 MB) containing all RefSeq viral genomes. Because it lacks the massive background of bacterial and human sequences, it requires a fraction of the memory to run.

```bash
# Create a directory for the viral database
mkdir -p data/db/viral
cd data/db/viral

# Download the pre-built viral database archive
wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20240904.tar.gz

# Extract the archive
tar -xvzf k2_viral_20240904.tar.gz

# Clean up the compressed file
rm k2_viral_20240904.tar.gz
cd ../../..

```

## Running Kraken2 on Our Samples

Now that our tools and databases are ready, it is time to classify our reads. We will run both the clinical patient sample (`mev-pat-toy`) and the wastewater sample (`mev-ww-toy`) against **both** databases. This will generate four separate sets of results for us to compare.

### 1. Analyzing the Clinical Sample

First, we will classify the clinical patient sample. Since we are using Docker, all file paths must be relative to your current working directory (`data/`).

```bash
# Run the clinical sample against the Standard 8GB Database
kraken2 --db data/db/standard_8gb \
  --paired data/mev-pat-toy_R1.fastq.gz data/mev-pat-toy_R2.fastq.gz \
  --report data/mev-pat-toy_standard.report \
  --output data/mev-pat-toy_standard.kraken

# Run the clinical sample against the Viral Database
kraken2 --db data/db/viral \
  --paired data/mev-pat-toy_R1.fastq.gz data/mev-pat-toy_R2.fastq.gz \
  --report data/mev-pat-toy_viral.report \
  --output data/mev-pat-toy_viral.kraken

```

> **Memory Watch:** You may notice that the command utilizing the `standard_8gb` database takes significantly longer to load into memory before the classification begins. This is because Kraken2 maps the entire database into RAM. In our 4GB free-tier Codespace, the system has to work hard to manage this process. Conversely, the smaller viral database will load almost instantly.

### 2. Analyzing the Wastewater Sample

Next, we will repeat the exact same process for our environmental wastewater sample.

```bash
# Run the wastewater sample against the Standard 8GB Database
kraken2 --db data/db/standard_8gb \
  --paired data/mev-ww-toy_R1.fastq.gz data/mev-ww-toy_R2.fastq.gz \
  --report data/mev-ww-toy_standard.report \
  --output data/mev-ww-toy_standard.kraken

# Run the wastewater sample against the Viral Database
kraken2 --db data/db/viral \
  --paired data/mev-ww-toy_R1.fastq.gz data/mev-ww-toy_R2.fastq.gz \
  --report data/mev-ww-toy_viral.report \
  --output data/mev-ww-toy_viral.kraken

```

## Parsing and Combining Results with KrakenTools

Instead of opening four separate report text files, we will use **KrakenTools** to merge our data into a single master table. This allows us to directly observe side-by-side how the Standard 8GB and Viral databases shifted our classification results for the exact same samples.

### Merging the Clinical Sample Reports

We will merge the two clinical patient reports (`mev-pat-toy`) so we can compare how the 8GB database performed versus the Viral database.

```bash
# Combine the clinical reports for side-by-side comparison
combine_kreports \
  -r data/mev-pat-toy_standard.report data/mev-pat-toy_viral.report \
  -o data/clinical_db_comparison.txt \
  --sample-names Standard_8GB Viral

# View the combined results
column -t -s $'\t' data/clinical_db_comparison.txt | less -S

```

### Merging the Wastewater Sample Reports

We will repeat the same step for the environmental wastewater sample.

```bash
# Combine the wastewater reports for side-by-side comparison
combine_kreports \
  -r data/mev-ww-toy_standard.report data/mev-ww-toy_viral.report \
  -o data/ww_db_comparison.txt \
  --sample-names Standard_8GB Viral

# View the combined results
column -t -s $'\t' data/ww_db_comparison.txt | less -S

```

> **Navigating the output:** Because the combined text files can be quite wide, we are piping the output into `less -S`. This allows you to use your left and right arrow keys to scroll horizontally and view all the columns. Press `q` to exit the viewer.