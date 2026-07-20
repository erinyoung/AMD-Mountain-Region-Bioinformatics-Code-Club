# Taxonomic Classification with Kraken2

## Session Overview

The primary objective of this 30-minute session is to understand how to use Kraken2 and some of the associated caveats.

By the end of this 30-minute code-along, participants will be able to:

* **Deploy containerized workflows:** Continue utilizing Docker to seamlessly run Kraken2 and KrakenTools without the need for complex local software compilation.
* **Execute k-mer based classification:** Run FASTQ files through Kraken2 to assign taxonomic labels to short DNA reads.
* **Evaluate database dependencies:** Explain why running the exact same sample against a standard 8GB database versus a targeted viral database yields fundamentally different results.

## References
* https://github.com/DerrickWood/kraken2
* https://github.com/jenniferlu717/KrakenTools
* https://en.wikipedia.org/wiki/K-mer
* Wood DE, Lu J, Langmead B. Improved metagenomic analysis with Kraken 2. Genome Biol. 2019 Nov 28;20(1):257. doi: 10.1186/s13059-019-1891-0. PMID: 31779668; PMCID: PMC6883579.
* Liu Y, Ghaffari MH, Ma T, Tu Y. Impact of database choice and confidence score on the performance of taxonomic classification using Kraken2. aBIOTECH. 2024 Jul 31;5(4):465-475. doi: 10.1007/s42994-024-00178-0. PMID: 39650139; PMCID: PMC11624175.
* Lu J, Rincon N, Wood DE, Breitwieser FP, Pockrandt C, Langmead B, Salzberg SL, Steinegger M. Metagenome analysis using the Kraken software suite. Nat Protoc. 2022 Dec;17(12):2815-2839. doi: 10.1038/s41596-022-00738-y. Epub 2022 Sep 28. Erratum in: Nat Protoc. 2026 Feb;21(2):872. doi: 10.1038/s41596-024-01064-1. PMID: 36171387; PMCID: PMC9725748.
* Kayikcioglu T, Amirzadegan J, Rand H, Tesfaldet B, Timme RE, Pettengill JB. Performance of methods for SARS-CoV-2 variant detection and abundance estimation within mixed population samples. PeerJ. 2023 Jan 26;11:e14596. doi: 10.7717/peerj.14596. PMID: 36721781; PMCID: PMC9884472.
* Bradford LM, Carrillo C, Wong A. Managing false positives during detection of pathogen sequences in shotgun metagenomics datasets. BMC Bioinformatics. 2024 Dec 3;25(1):372. doi: 10.1186/s12859-024-05952-x. PMID: 39627685; PMCID: PMC11613480.

## How Kraken2 is Used in Bioinformatics

At its core, [Kraken2](https://github.com/DerrickWood/kraken2) is a highly efficient taxonomic classification system. While aligners like [Minimap2](https://github.com/lh3/minimap2) are designed to map reads to specific coordinates on a single reference genome, Kraken2 is designed to quickly answer a broader question: *"What exactly is in this sample?"*

Instead of aligning full sequences, Kraken2 uses a "[k-mer](https://en.wikipedia.org/wiki/K-mer)" based approach. It chops each short sequence read into even smaller, overlapping fragments of a specific length (k-mers) and searches for exact matches within a massive, pre-indexed database of known genomes. This exact-matching technique allows Kraken2 to classify millions of reads quickly, making it a staple tool in modern public health pipelines.

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

A critical concept in public health bioinformatics is that **classification results are entirely dependent on the contents of the database used.**

In this session, we will investigate this dependency by running our measles FASTQ files through two distinct databases:

* **The Standard 8GB Database:** A broad, size-capped database that includes a generalized mix of bacteria, archaea, and viruses. While excellent for general metagenomics, it may lack the granular depth needed for specific pathogen surveillance.
* **The Viral Database:** A highly targeted database optimized specifically for viral genomics, which typically yields higher sensitivity and more specific lineage calls for viral isolates and wastewater streams.

## Tool Installation
 
Nothing will be installed in this code club, instead we will utilize [StaPH-B's docker images](https://github.com/StaPH-B/docker-builds) for [Kraken2](https://hub.docker.com/r/staphb/kraken2) and [KrakenTools](https://hub.docker.com/r/staphb/krakentools). 

We are going to set up an alias to run the docker commands. This allows us to avoid a massive Docker command every single time we want to run a tool. It's shortcut for command-line commands. Any generated alias will not be saved between GitHub CodeSpace sessions.

### Pulling Kraken2
```bash
docker pull staphb/kraken2:2.17.1
alias kraken2='docker run --rm -v "$(pwd):/data" -w /data staphb/kraken2:2.17.1 kraken2'
```

### Pulling KrakenTools
```bash
docker pull staphb/krakentools:d4a2fbe
alias amrfinder='docker run --rm -v "$(pwd):/data" -w /data staphb/krakentools:d4a2fbe amrfinder'
```

## Download some test files

We are going to download two FASTQ files for SRR35981380. These FASTQ files were generated as a pair on an Illumina instrument with amplicon-based library prep for Measles.
* Public NCBI page for SRR35981380 : https://www.ncbi.nlm.nih.gov/sra/?term=SRR35981380
* Krona report: https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR35981380&display=analysis

### Downloading the FASTQ files

```bash
# Downloading Read 1, also known as the "Forward" Read
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR359/080/SRR35981380/SRR35981380_1.fastq.gz

# Downloading Read 2, also known as the "Reverse" Read
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR359/080/SRR35981380/SRR35981380_2.fastq.gz
```

## Downloading Pre-Built Databases

There are several pre-built databases that are widely used for Kraken2 listed at https://benlangmead.github.io/aws-indexes/k2. These are maintained by the Langmead Lab.

### 1. The Standard 8GB Database

This is a size-capped version of the massive Standard database. It includes a broad reference library of archaea, bacteria, viruses, plasmids, and the human genome.

```bash
# Create a directory for the database
mkdir -p standard_8gb
cd standard_8gb

# Download the pre-built 8GB database archive (took 3-3.5 minutes when preparing these materials)
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20260626.tar.gz

# Extract the archive
tar -xvzf k2_standard_08_GB_20260626.tar.gz

# Clean up the compressed file to save disk space
rm k2_standard_08_GB_20260626.tar.gz
cd ..

```

There should now be several files that can be viewed with `ls`:

```bash
ls standard_8gb/
```

```output
database100mers.kmer_distrib  database50mers.kmer_distrib  library_report.tsv  taxo.k2d
database150mers.kmer_distrib  database75mers.kmer_distrib  names.dmp           unmapped_accessions.txt
database200mers.kmer_distrib  hash.k2d                     nodes.dmp
database250mers.kmer_distrib  inspect.txt                  opts.k2d
database300mers.kmer_distrib  ktaxonomy.tsv                seqid2taxid.map
```

### 2. The Viral Database

This is a much smaller, highly targeted database containing all RefSeq viral genomes. Because it lacks the massive background of bacterial and human sequences, it requires a fraction of the memory to run.

```bash
# Create a directory for the viral database
mkdir -p viral
cd viral

# Download the pre-built viral database archive
wget https://genome-idx.s3.amazonaws.com/kraken/k2_viral_20260626.tar.gz

# Extract the archive
tar -xvzf k2_viral_20260626.tar.gz

# Clean up the compressed file
rm k2_viral_20260626.tar.gz
cd ../

```

There should now be several files that can be viewed with `ls`:

```bash
ls viral/
```

```output
database100mers.kmer_distrib  database300mers.kmer_distrib  inspect.txt         nodes.dmp
database150mers.kmer_distrib  database50mers.kmer_distrib   ktaxonomy.tsv       opts.k2d
database200mers.kmer_distrib  database75mers.kmer_distrib   library_report.tsv  seqid2taxid.map
database250mers.kmer_distrib  hash.k2d                      names.dmp           taxo.k2d
```

### Image with included Databases

StaPH-B maintains a Kraken2 with an included viral database image. Check Dockerhub at https://hub.docker.com/r/staphb/kraken2/tags or the corresponding GitHub repository at https://github.com/StaPH-B/docker-builds/tree/master/build-files/kraken2 and look for tags with `viral` in the name to find an image. As an example, `2.17.1-viral-20251015` contains kraken2 version `2.17.1` and the `20251015` viral database at `/kraken2_db`. 

To use:

```bash
# The command to use docker
# --rm : removes the container after use
# -v "$(pwd):/data" : mounts the current directory to the /data directory in the docker container
# -w /data : sets the working directory to data (not really needed, but is good to use)
# staphb/kraken2:2.17.1-viral-20251015 : is the image and tag we will be using
# kraken2* : the kraken2 command
# Replace ... with the remaining kraken2 command
docker run --rm -v "$(pwd):/data" -w /data staphb/kraken2:2.17.1-viral-20251015 \
  kraken2 --db /kraken2_db \
  ...
```

## Running Kraken2 on Our Samples

Now that our tools, files, and databases are ready, it is time to classify some reads.

### Using the 8G Standard Database

First, classify the reads in the FASTQ files with the Standard 8GB Database that we downloaded into `standard_8gb`.

```bash
# Run the sample against the Standard 8GB Database
kraken2 --db standard_8gb \
  --paired SRR35981380_1.fastq.gz SRR35981380_2.fastq.gz \
  --report kraken2_standard.report \
  --output kraken2_standard.kraken
```

> **Memory Watch:** The command utilizing the `standard_8gb` database takes significantly longer to load into memory before the classification begins. This is because Kraken2 maps the **entire** database into RAM. In the free-tier Codespace, the system has to work hard to manage this process. Conversely, the smaller viral database will load almost instantly.

### Using the Viral Database

```bash
# Run the sample against the Viral Database
kraken2 --db viral \
  --paired SRR35981380_1.fastq.gz SRR35981380_2.fastq.gz \
  --report kraken2_viral.report \
  --output kraken2_viral.kraken
```

## Parsing and Combining Results with KrakenTools

**KrakenTools** can be used to merge our data into a single master table. This allows directly observation of results side-by-side.

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