# Taxonomic Classification with Kraken2

IMPORTANT INFORMATION: This code-along requires more than 8GB of memory. Please choose an option, like the 4 core, 16GB memory option in GitHub codespaces.

## Session Overview

The primary objective of this 30-minute session is to understand how to use Kraken2 and some of the associated caveats.

By the end of this 30-minute code-along, participants will be able to:

* **Deploy containerized workflows:** Continue utilizing Docker to seamlessly run Kraken2 and KrakenTools without the need for complex local software compilation.
* **Execute k-mer based classification:** Run FASTQ files through Kraken2 to assign taxonomic labels to short DNA reads.
* **Evaluate database dependencies:** Explain why running the exact same sample against a standard 8GB database versus a targeted viral database yields fundamentally different results.

## Quickstart Setup

The setup for this will take several minutes, which is a large portion of the 30 minute interval. To help things run smoothly, a bash script has been created that will
1. set up the liases
2. download the test FASTQ files
3. download the kraken2 databases

```bash
source bin/setup_2026-07-23.sh
```

## References
* https://github.com/DerrickWood/kraken2
* https://github.com/jenniferlu717/KrakenTools
* https://en.wikipedia.org/wiki/K-mer
* https://github.com/multiqc/multiqc
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
docker pull staphb/krakentools:1.2.1
alias combine_kreports='docker run --rm -v "$(pwd):/data" -w /data staphb/krakentools:1.2.1 combine_kreports.py'
```

### Pulling MultiQC
```bash
docker pull staphb/multiqc:1.35 multiqc
alias multiqc='docker run --rm -v "$(pwd):/data" -w /data staphb/multiqc:1.35 multiqc'
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

# Extract the archive (took an additional ~5 minutes)
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
# Remember, in this instance kraken2 is an alias
# --paired indicates that a pair of FASTQ files are being used as input
# --report sets the name of the kraken2 report
# --output sets the name of the kraken2 output
kraken2 --db standard_8gb \
  --paired SRR35981380_1.fastq.gz SRR35981380_2.fastq.gz \
  --report kraken2_standard.report \
  --output kraken2_standard.kraken
```

Something like the following should be printed to the screen
```output
Loading database information... done.
471103 sequences (101.58 Mbp) processed in 4.136s (6834.8 Kseq/m, 1473.74 Mbp/m).
  206482 sequences classified (43.83%)
  264621 sequences unclassified (56.17%)
```

And we have to files:

```output
$ head kraken2_standard.kraken 
U       SRR35981380.1   0       151|150 0:117 |:| 0:4 11234:5 0:107
U       SRR35981380.2   0       116|116 0:82 |:| 0:82
C       SRR35981380.3   11234   151|151 0:26 11234:8 0:7 11234:2 0:4 11234:5 0:65 |:| 0:80 11234:5 0:4 11234:2 0:7 11234:8 0:11
U       SRR35981380.4   0       68|68   0:34 |:| 0:34
C       SRR35981380.5   11234   106|106 0:55 11234:5 0:12 |:| 0:12 11234:5 0:55
C       SRR35981380.6   11240   151|149 0:84 11240:5 0:28 |:| 0:32 11240:5 0:78
U       SRR35981380.7   0       85|85   0:51 |:| 0:51
C       SRR35981380.8   11234   126|126 0:82 11234:5 0:5 |:| 0:5 11234:5 0:82
C       SRR35981380.9   11234   124|124 0:76 11234:1 0:13 |:| 0:13 11234:1 0:76
U       SRR35981380.10  0       116|116 0:82 |:| 0:82
```

And

```output
$ head kraken2_standard.report 
 56.17  264621  264621  U       0       unclassified
 43.83  206482  7       R       1       root
 41.70  196459  0       R1      10239     Viruses
 41.70  196459  0       R2      2559587     Riboviria
 41.70  196459  0       K       2732396       Orthornavirae
 41.70  196459  0       P       2497569         Negarnaviricota
 41.70  196459  0       P1      2497570           Haploviricotina
 41.70  196459  0       C       2497574             Monjiviricetes
 41.70  196459  0       O       11157                 Mononegavirales
 41.70  196459  0       F       11158                   Paramyxoviridae
```

> **Memory Watch:** The command utilizing the `standard_8gb` database takes significantly longer to load into memory before the classification begins. This is because Kraken2 maps the **entire** database into RAM. If this cannot happen, as in the current lowest-tier in the free-tier Codespace options, Kraken2 will fail to run.

### Using the Viral Database

Running on the viral database is similar

```bash
# Run the sample against the Viral Database
kraken2 --db viral \
  --paired SRR35981380_1.fastq.gz SRR35981380_2.fastq.gz \
  --report kraken2_viral.report \
  --output kraken2_viral.kraken
```

Something like the following should be printed to the screen
```output
Loading database information... done.
471103 sequences (101.58 Mbp) processed in 5.404s (5230.3 Kseq/m, 1127.78 Mbp/m).
  429089 sequences classified (91.08%)
  42014 sequences unclassified (8.92%)
```

**Woah! Look at how many more reads were classified!!!**

And the output files look similar. Below is the Kraken2 output.

```output
$ head kraken2_viral.kraken 
C       SRR35981380.1   11234   151|150 0:11 11234:2 0:3 11234:3 0:13 11234:85 |:| 0:4 11234:91 0:13 11234:3 0:3 11234:2
C       SRR35981380.2   11234   116|116 0:4 11234:6 0:11 11234:61 |:| 11234:61 0:11 11234:6 0:4
C       SRR35981380.3   11234   151|151 0:12 11234:1 0:11 11234:30 0:24 11234:3 0:34 11234:2 |:| 0:5 11234:12 0:34 11234:3 0:24 11234:30 0:9
C       SRR35981380.4   11234   68|68   0:7 11234:5 0:22 |:| 0:22 11234:5 0:7
C       SRR35981380.5   11234   106|106 11234:12 0:3 11234:5 0:35 11234:5 0:1 11234:11 |:| 11234:11 0:1 11234:5 0:35 11234:5 0:3 11234:12
C       SRR35981380.6   11234   151|149 0:47 11234:1 0:3 11234:7 0:1 11234:6 0:1 11234:10 0:5 11234:2 0:1 11240:5 0:18 11234:5 0:5 |:| 0:9 11234:5 0:18 11240:5 0:1 11234:2 0:5 11234:10 0:1 11234:6 0:1 11234:7 0:3 11234:1 0:41
U       SRR35981380.7   0       85|85   0:51 |:| 0:51
C       SRR35981380.8   11234   126|126 0:4 11234:6 0:13 11234:2 0:54 11234:2 0:1 11234:10 |:| 11234:10 0:1 11234:2 0:54 11234:2 0:13 11234:6 0:4
C       SRR35981380.9   11234   124|124 0:5 11234:2 0:29 11234:9 0:3 11234:1 0:5 11234:36 |:| 11234:36 0:5 11234:1 0:3 11234:9 0:11 11234:9 0:9 11234:2 0:5
C       SRR35981380.10  11234   116|116 0:26 11234:48 0:8 |:| 0:13 11234:1 0:8 11234:34 0:26
```

The Kraken2 report
```output
$ head kraken2_viral.report 
  8.92  42014   42014   U       0       unclassified
 91.08  429089  0       R       1       root
 91.08  429089  1       R1      10239     Viruses
 91.06  428989  0       R2      2559587     Riboviria
 91.06  428988  0       K       2732396       Orthornavirae
 91.06  428987  0       P       2497569         Negarnaviricota
 91.06  428987  0       P1      2497570           Haploviricotina
 91.06  428987  0       C       2497574             Monjiviricetes
 91.06  428987  0       O       11157                 Mononegavirales
 91.06  428987  0       F       11158                   Paramyxoviridae
```


## Parsing and Combining Results with KrakenTools

The files generated from Kraken2 can be difficult to read on their own. It is recommended to use additional bioinformatic tools, such as [KrakenTools](https://github.com/jenniferlu717/KrakenTools), [Braken](https://github.com/jenniferlu717/Bracken), or [MultiQC](https://github.com/multiqc/multiqc) to get full use of these results.

This excersize will use **KrakenTools** to merge the generated data into a single master table. This allows directly observation of results side-by-side. KrakenTools has more functionality than this, but it's a small example.

### Merging Reports

```bash
# Kraken2 reports for side-by-side comparison
combine_kreports \
  -r kraken2_standard.report kraken2_viral.report  \
  -o combined_reports.tsv  \
  --display-headers \
  --sample-names standard viral
```

This prints the following to the screen
```output
>>STEP 1: READING REPORTS
        2/2 samples processed
>>STEP 2: WRITING NEW REPORT HEADERS
>>STEP 3: PRINTING REPORT
```

And there are more samples in the Report

```output
# head combined_reports.tsv 
#Number of Samples: 2
#Total Number of Reads: 942206
#standard       kraken2_standard.report
#viral  kraken2_viral.report
#perc   tot_all tot_lvl standard_all    standard_lvl    viral_all       viral_lvl       lvl_type        taxid   name
32.5444 306635  306635  264621  264621  42014   42014   U       0       unclassified
67.4556 635571  7       206482  7       429089  0       R       1       root
66.3919 625548  1       196459  0       429089  1       R1      10239     Viruses
66.3812 625448  0       196459  0       428989  0       R2      2559587     Riboviria
66.3811 625447  0       196459  0       428988  0       K       2732396       Orthornavirae
```

## Visualizing with MultiQC

MultiQC has a module to assist in visualizing Kraken2 results as a stacked bar graph.

```bash
multiqc .
```

Results can now be visualized in `multiqc_report.html` and/or shared with colleagues.