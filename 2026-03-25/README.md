# Bioinformatic File Essentials

## Session Overview:

The primary objective of this 30-minute session is the exploration of standard genomic file formats. Understanding these formats is critical for data quality control, troubleshooting, and interpretation of results in public health surveillance.

| Format | Full Name | Primary Use Case |
| :--- | :--- | :--- |
| **FASTQ** | Fast Quality | Storage of raw sequence reads and their corresponding base-call quality scores. |
| **FASTA** | Pearson Format | Representation of reference genomes or consensus sequences. |
| **BAM** | Binary Alignment Map | Compressed binary format representing the alignment of reads to a reference sequence. |
| **VCF** | Variant Call Format | Standardized format for storing genomic variations (SNPs, Indels, etc.) relative to a reference. |
| **BED** | Browser Extensible Data | Coordinate-based format used to define specific regions of interest, such as gene boundaries. |

## Tool instalation

These could all be pre-loaded into github codespaces, but this is a training so they are not. Installation of these tools is optional for this particular training, and are only recommended.


### Samtools

Samtools is a fundamental software suite designed for the manipulation and analysis of high-throughput sequencing data. It provides the primary interface for interacting with SAM (Sequence Alignment/Map), BAM (Binary Alignment/Map), and CRAM formats (not covered in this training). Its core utilities facilitate the filtering, sorting, indexing, and statistical assessment of read alignments. Within public health bioinformatics pipelines, Samtools is a critical component for converting binary alignment data into human-readable text and preparing files for downstream variant calling or visualization in genomic browsers.

```bash
# Create local directories for organization
mkdir -p $HOME/software
cd $HOME/software

# Build Samtools from Source
wget https://github.com/samtools/samtools/releases/download/1.19/samtools-1.19.tar.bz2
tar -xf samtools-1.19.tar.bz2
cd samtools-1.19
./configure --prefix=$HOME
make
make install

# Update the PATH to recognize the $HOME/bin directory
export PATH=$HOME/bin:$PATH

# Verification of successful setup
samtools --version | head -n 1

# Return home 
cd /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club
```

### bcftools

BCFtools is a specialized suite of utilities for manipulating variant calls stored in the Variant Call Format (VCF) and its binary counterpart, BCF. It is primarily utilized for variant calling—the process of identifying genomic differences between a sample and a reference—as well as for filtering, merging, and intersecting datasets. Within public health laboratories, BCFtools is an essential tool for extracting high-confidence mutations, such as those associated with antimicrobial resistance (AMR) or lineage-specific markers in pathogen surveillance.

```bash
# Create local directories for organization
mkdir -p $HOME/software
cd $HOME/software

# Build Bcftools from Source
wget https://github.com/samtools/bcftools/releases/download/1.19/bcftools-1.19.tar.bz2
tar -xf bcftools-1.19.tar.bz2
cd bcftools-1.19
./configure --prefix=$HOME
make
make install

# Update the PATH to recognize the $HOME/bin directory
export PATH=$HOME/bin:$PATH

# Verification of successful setup
bcftools --version | head -n 1

# Return home 
cd /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club
```

### minimap2

Minimap2 is a highly efficient, versatile sequence alignment program used to map DNA or mRNA sequences against a large reference database. It is the industry standard for aligning long-read sequencing data, such as Oxford Nanopore or PacBio, and is also frequently used for short-read mapping and assembly-to-reference alignment. In a standard bioinformatic pipeline, Minimap2 serves as the alignment engine that compares raw FASTQ reads to a FASTA reference genome, generating the spatial coordinates necessary to produce SAM and BAM files.

```bash
# Create local directories for organization
mkdir -p $HOME/software
cd $HOME/software

# Download Minimap2 Pre-compiled Binary
wget https://github.com/lh3/minimap2/releases/download/v2.28/minimap2-2.28_x64-linux.tar.bz2
tar -xf minimap2-2.28_x64-linux.tar.bz2

# Update the PATH to recognize the $HOME/software/minimap2-2.28_x64-linux directory
export PATH=$HOME/software/minimap2-2.28_x64-linux:$PATH

# Verification of successful setup
minimap2 --version | head -n 1

# Return home 
cd /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club
```

## Files used in this exercise
The `data/` directory contains paired-end reads, sam files, and variant information in a vcf for two different Measles virus (MeV) samples: a patient clinical sample (`mev-pat-toy`) and a wastewater surveillance sample (`mev-ww-toy`), a reference fasta file, and a bedfile.

## Pre-FASTQ: Raw Instrument Output

The journey of genomic data begins on the sequencing instrument in proprietary formats that are not yet human-readable or directly compatible with standard alignment tools. These "raw-raw" data files contain the fundamental physical signals measured during the sequencing process. These files are uncommon, so are not covered in this training.

### Illumina: BCL Files
Illumina platforms generate **BCL (Binary Base Call)** files. These files store the light intensity signals captured for each nucleotide during the sequencing run. To become useful for bioinformatics, these files must undergo "basecalling" and "demultiplexing" (typically using tools like `bcl2fastq` or `BCL Convert`) to produce the FASTQ files used in analysis.

### Oxford Nanopore: POD5/FAST5 Files
Nanopore sequencers generate **POD5** (the current standard) or **FAST5** (legacy) files. These store the raw electrical current measurements (in picoamperes) as DNA or RNA molecules pass through a protein nanopore. A specialized "basecaller," such as **Dorado**, is required to translate these electrical squiggles into the nucleotide sequences found in a FASTQ file.


## FASTQ: The Raw Data

The FASTQ format is the standard text-based format for storing both biological sequences and corresponding quality scores. In public health bioinformatics, this is typically the primary file generated by a sequencing platform—such as Illumina or Oxford Nanopore—prior to downstream processing.

### The Four-Line Structure
Every sequencing read in a FASTQ file is represented by a specific four-line block:

| Line | Content | Description |
| :--- | :--- | :--- |
| **1** | **Sequence Header** | Begins with `@` and contains unique metadata about the sequencer, flow cell, and read coordinates. |
| **2** | **Sequence** | The raw nucleotide sequence (A, C, T, G, and N for ambiguous calls). |
| **3** | **Separator** | A plus sign (`+`) acting as a divider, occasionally repeating the header information. |
| **4** | **Quality Scores** | An ASCII-encoded string representing the Phred quality score for each base in Line 2. |

### Decompressing the files for interaction
```bash
# copy a fastq file for decompression
cp data/mev-pat-toy_R1.fastq.gz .
gunzip mev-pat-toy_R1.fastq.gz
```

This file is now human-readable. 

To count the total number of lines in fastq file (keeping in mind that every 4 lines equals 1 read):

```bash
# Count total lines
wc -l mev-pat-toy_R1.fastq
```

### Quality Scores (Phred)
Quality scores in Line 4 provide a statistical estimate of the probability that a base call is incorrect. These are encoded in ASCII characters to conserve storage space. A common standard is Phred+33, where higher-value characters (such as 'I' or 'J') represent high-confidence calls, and lower-value characters (such as '!' or '#') represent higher error probabilities.


### Viewing Raw Reads on the Command line

Because these files are compressed (indicated by the `.gz` extension), the `zcat` or `zless` command must be used to view the content without decompressing the file on disk.
```bash
# View the first four lines (one read) of the forward (R1) file
zcat data/mev-pat-toy_R1.fastq.gz | head -n 4
```

To count the total number of lines in the wastewater sample (keeping in mind that every 4 lines equals 1 read):

```bash
# Count total lines
zcat data/mev-ww-toy_R1.fastq.gz | wc -l
```

## FASTA: The Reference Blueprint

The FASTA format is the standard text-based format for representing nucleotide or peptide sequences. While a FASTQ file contains millions of short, raw fragments from a sample, a FASTA file typically contains the complete, "consensus" sequence used as a reference for comparison.

### The Two-Part Structure
A FASTA file consists of a minimum of two lines per entry:

| Component | Description |
| :--- | :--- |
| **Header Line** | Begins with a greater-than symbol (`>`) followed by a unique identifier (e.g., Accession Number) and an optional description. |
| **Sequence Line** | The raw sequence of nucleotides (A, C, T, G, N) or amino acids. This can span multiple lines. |

### Exploring the Reference
The reference genome provided (`NC_001498.1.fasta`) represents the Measles morbillivirus (MeV) genome, which is approximately 15,894 base pairs in length. Fasta files are also sometimes compressed and end in `.gz`.

To view the header and the beginning of the reference sequence:

```bash
# Display the first 5 lines of the FASTA file
head -n 5 data/NC_001498.1.fasta
```

### Reference Indexing (.fai)
The file `data/NC_001498.1.fasta.fai` is a small text index created by `samtools faidx`. This index allows bioinformatic tools to jump to specific coordinates within a large reference genome almost instantaneously, rather than reading the entire file from the beginning. This is essential for efficient alignment and variant calling.

To create an index
```bash
# copy the fasta file
cp data/NC_001498.1.fasta .
# index it with samtools
samtools faidx NC_001498.1.fasta
```

### Checking Sequence Length
The index file can be used to quickly determine the length of the reference sequence without opening the main FASTA file:
```bash
# the second column of the .fai file indicates the sequence length
cat NC_001498.1.fasta.fai
```

## Alignment: Bridging Raw Reads and the Reference

Alignment is the computational process of determining the most likely origin of each raw sequence read within the reference genome. By comparing the FASTQ fragments against the FASTA "blueprint," the spatial relationship between individual reads and the overall genomic structure is established.

### Mapping with Minimap2
Minimap2 is the alignment engine used to perform this mapping. The output of an aligner is typically a **SAM (Sequence Alignment/Map)** file, which is human-readable text. However, due to the large volume of data, this is immediately converted into a **BAM (Binary Alignment Map)** file for efficient storage and processing.

The following command demonstrates the process of mapping the patient sample (paired-end reads) to the measles reference genome. The output is piped directly into `samtools sort` to produce a coordinate-sorted BAM file.

#### Generating a SAM file
```bash
# Align reads to the reference and save as a SAM file
minimap2 -ax sr data/NC_001498.1.fasta \
    data/mev-pat-toy_R1.fastq.gz \
    data/mev-pat-toy_R2.fastq.gz > mev-pat-toy.sam

# Inspect the first few lines of the SAM file
head -n 20 mev-pat-toy.sam
```

### Anatomy of a SAM File
A SAM file consists of two primary sections:

1.  **The Header Section**: Lines starting with `@`. These provide metadata about the reference sequences (`@SQ`), the software used for alignment (`@PG`), and the read groups (`@RG`).
2.  **The Alignment Section**: Tab-separated lines representing individual read alignments.

#### Core Alignment Columns
Each alignment line contains at least 11 mandatory fields:

| Column | Name | Description |
| :--- | :--- | :--- |
| **1** | **QNAME** | Query template NAME (the read ID from the FASTQ). |
| **2** | **FLAG** | Bitwise FLAG (indicates if the read is paired, mapped, etc.). |
| **3** | **RNAME** | Reference sequence NAME (e.g., NC_001498.1). |
| **4** | **POS** | 1-based leftmost mapping POSition. |
| **5** | **MAPQ** | MAPping Quality (likelihood that the alignment is correct). |
| **6** | **CIGAR** | Concise Idiosyncratic Gapped Alignment Report (e.g., 150M). |
| **7** | **RNEXT** | Reference name of the mate/next read. |
| **8** | **PNEXT** | Position of the mate/next read. |
| **9** | **TLEN** | Observed Template LENgth. |
| **10** | **SEQ** | Segment SEQuence. |
| **11** | **QUAL** | ASCII of Phred-scaled base QUALity. |

## SAM Header Variability and Data Provenance

While the structural format of a SAM file is standardized by the Global Alliance for Genomics and Health (GA4GH), the metadata contained within the header section (lines starting with `@`) varies significantly depending on the alignment tool used. This section, specifically the **@PG (Program)** tag, serves as a record of the bioinformatic "provenance" of the file.

### The @PG Tag
The `@PG` tag records the specific software name, version, and the exact command-line parameters used to generate the alignment.

### Comparison of Header Information

| Aligner | Typical @PG Content | Known For |
| :--- | :--- | :--- |
| **Minimap2** | Version, Preset mode, Reference | High speed; versatile for both long and short reads. |
| **BWA-MEM** | Version, Command string | The traditional gold standard for Illumina short-read mapping. |
| **BBMap** | Version, Extensive parameter list | High sensitivity; handles varied read lengths and high error rates well. |
| **Bowtie2** | Version, Options, Alignment mode | Optimized for fast, memory-efficient short-read alignment. |

### Importance of Header Inspection
Inspecting the header is the most reliable method for determining how a SAM/BAM file was created if the original scripts or logs are missing. This is particularly relevant when merging datasets from different laboratories or platforms.

## BAM: Binary Alignment Map

While SAM files are useful for manual inspection, they are inefficient for large-scale genomic data storage and processing. The **BAM** (Binary Alignment Map) format is the compressed, binary equivalent of a SAM file.

### Advantages of the BAM Format
1.  **Storage Efficiency**: BAM files are significantly smaller than SAM files due to BGZF compression.
2.  **Computational Speed**: Bioinformatic tools can traverse binary data faster than text-based data.
3.  **Indexing**: BAM files can be indexed (`.bai`), allowing tools like IGV (Integrative Genomics Viewer) to load data for specific genomic coordinates without reading the entire file.

### Converting and Sorting
A raw SAM file is typically unsorted. For downstream analysis and indexing, the alignments must be sorted by genomic coordinate.

```bash
# Convert SAM to a sorted BAM file
samtools sort -o mev-pat-toy.bam mev-pat-toy.sam

# Index the BAM file (creates mev-pat-toy.bam.bai)
samtools index mev-pat-toy.bam
```

### Alignment, Coverting, and Sorting

These steps can all be done "one one line"
```bash
minimap2 -ax sr data/NC_001498.1.fasta data/mev-ww-toy_R1.fastq.gz data/mev-ww-toy_R2.fastq.gz | \
    samtools view -bS - | samtools sort -o mev-ww-toy.bam
    samtools index mev-ww-toy.bam
```

#### Command Example: Viewing Only the Header
To inspect the metadata without scrolling through millions of alignment lines:

```bash
# View the header of a BAM file
samtools view -H mev-pat-toy.bam
```

### Alignment Quality Control with Samtools

Quality control is a critical phase of the bioinformatic pipeline, ensuring that the alignment data meets the necessary thresholds for reliable downstream analysis. The `samtools` suite provides three primary utilities for assessing the integrity and characteristics of a BAM file:

1.  **samtools flagstat**: This utility provides a rapid, high-level summary of the bitwise flags within a BAM file. It reports essential metrics such as the total number of reads, the percentage of reads that successfully mapped to the reference, and the number of properly paired reads. This is the standard first step for identifying major mapping failures.
2.  **samtools stats**: For a more granular investigation, this command generates an exhaustive report of the alignment data. It includes statistics on read length distributions, GC content, base qualities, and mismatch rates. This output is often used to generate visual diagnostic plots to identify systemic sequencing errors or library preparation issues.
3.  **samtools coverage**: This tool calculates the sequencing depth and breadth across the reference genome. It provides a tabular summary showing what percentage of the genome is covered by at least one read and the average number of times each base was sequenced (mean depth). In public health surveillance, this is vital for determining if a sample has sufficient data to generate a high-quality consensus sequence.


#### Command Examples: QC Inspection

```bash
# Generate a quick summary of mapping percentages
samtools flagstat mev-pat-toy.bam

# Calculate coverage and depth across the reference
samtools coverage mev-pat-toy.bam

# Generate a detailed statistical report
samtools stats mev-pat-toy.bam | head -n 30
```

## BED: Browser Extensible Data

The **BED** (Browser Extensible Data) format is a tab-delimited text file used to define specific genomic coordinates. In public health bioinformatics, BED files are frequently used to specify "targets," such as individual genes, primer binding sites, or regions of interest for deep sequencing (e.g., the spike protein in SARS-CoV-2).

### The Three Mandatory Columns
A standard BED file must contain at least three columns, though it can extend to 12 for complex visualizations.

| Column | Name | Description |
| :--- | :--- | :--- |
| **1** | **chrom** | The name of the chromosome or reference sequence (e.g., NC_001498.1). |
| **2** | **chromStart** | The 0-based starting position of the feature. |
| **3** | **chromEnd** | The 1-based ending position of the feature. |

As a warning, there are official versions of a BED file that require additional columns.

### Why Use BED Files?
BED files allow for "targeted" analysis. Instead of processing an entire genome, tools can be instructed to only look at specific regions. This is particularly useful for:
1. **Subsetting BAM files**: Extracting only the reads that map to a specific gene.
2. **Calculating Coverage**: Determining the sequencing depth over a specific set of primers.
3. **Masking**: Identifying regions that should be ignored during variant calling.

### Exploring the Dataset
The file `data/targets.bed` defines specific regions of the Measles virus genome, such as the Nucleoprotein (N) or Hemagglutinin (H) genes.

#### Command Example: Viewing the BED File
```bash
# View the coordinates defined in the target file
cat data/targets.bed
```

#### Command Example: Filtering a BAM File by Region
The samtools view command can use a BED file (via the -L flag) to output only the reads that overlap with the regions defined in the BED file.
```bash
# Extract reads from the patient BAM that overlap with the target regions
samtools view -L data/targets.bed mev-pat-toy.bam | head -n 5
```

#### Command Example: Counting Targeted Reads
To compare how many reads mapped to the whole genome versus the specific targets defined in the BED file:

```bash
# Count total reads in the BAM
samtools view -c mev-pat-toy.bam

# Count reads only within the BED regions
samtools view -c -L data/targets.bed mev-pat-toy.bam
```

## VCF: Variant Call Format

The **VCF** (Variant Call Format) is the standard format for storing gene sequence variations, including single nucleotide polymorphisms (SNPs), insertions, deletions, and structural variants. In a bioinformatic pipeline, a VCF is typically the final output generated by a "variant caller" (such as BCFtools, GATK, or FreeBayes) after comparing a BAM file against a FASTA reference.

### The Three Components of a VCF
A VCF file is divided into three distinct sections:

1.  **Meta-information Lines**: Start with `##`. These define the version of the VCF, the reference used, and provide "dictionaries" that explain the abbreviations found in the data columns.
2.  **The Header Line**: Starts with a single `#`. This line defines the column names (CHROM, POS, ID, etc.) and identifies the sample names present in the file.
3.  **Data Lines**: Each line represents a specific variant at a specific genomic position.

### Core Data Columns
Each variant line contains eight mandatory columns, followed by format and sample-specific information:

| Column | Name | Description |
| :--- | :--- | :--- |
| **CHROM** | Chromosome | The reference sequence name. |
| **POS** | Position | The 1-based coordinate of the variant. |
| **REF** | Reference | The allele (nucleotide) found in the reference genome. |
| **ALT** | Alternate | The allele(s) found in the sample. |
| **QUAL** | Quality | A Phred-scaled probability that the variant call is correct. |
| **FILTER** | Filter | Status of quality filters (e.g., "PASS" or "LowQual"). |
| **INFO** | Information | Global metadata about the variant (e.g., total depth, strand bias). |
| **FORMAT** | Format | Defines the data types provided for each sample (e.g., Genotype, Depth). |

### Exploring the VCF
The file `data/training_comparison.vcf` contains a comparison of mutations found in the measles virus datasets.

#### Command Example: Viewing the Meta-information
To understand how the variants were called and what the abbreviations mean:

```bash
# View only the meta-information lines
grep "^##" data/mev_toy_variants.vcf
```

#### Command Example: Summary Statistics with BCFtools
BCFtools is used to generate a high-level summary of the variant types found in a file, such as the total number of SNPs versus Indels.

```bash
# Generate a summary report of the VCF
bcftools stats data/mev_toy_variants.vcf | grep "^SN"
```

## Multi-Sample Variant Calling with BCFtools

Generating a VCF from multiple BAM files allows for the simultaneous identification and comparison of variants across different samples—in this case, a clinical patient sample (`mev-pat-toy.bam`) and a wastewater surveillance sample (`mev-ww-toy.bam`). This process uses a two-step pipeline that combines genotype likelihood generation with statistical calling.

### The Variant Calling Pipeline
1. bcftools mpileup: This utility scans the alignments and computes the likelihood of each possible genotype at every genomic position. It utilizes the reference FASTA file to determine which bases differ from the expected sequence.
2. bcftools call: This utility consumes the output of the pileup and applies a calling model to decide whether a position truly represents a variant or is likely the result of sequencing error.

#### Command Example: Generating a Multi-Sample VCF

The following command strings these two utilities together using a pipe (|) to generate a single VCF file containing data for both samples.
```bash
# Generate genotype likelihoods and call variants for both samples
bcftools mpileup -f data/NC_001498.1.fasta \
    mev-pat-toy.bam \
    mev-ww-toy.bam | \
    bcftools call -mv -o mev_toy_variants.vcf
```
### Parameter Breakdown

The following table details the specific flags used in the `bcftools` pipeline to generate the multi-sample VCF:

| Parameter | Function |
| :--- | :--- |
| **-f** | Specifies the reference FASTA file required for identifying mismatches. |
| **-m** | Invokes the multiallelic calling model, the current standard for modern pipelines. |
| **-v** | Instructs the tool to output only variant sites (SNPs and Indels), excluding reference-only positions. |
| **-o** | Specifies the filename for the resulting VCF. |



### Final Data Inspection

Following the generation of the VCF, the data columns at the end of the file provide a side-by-side comparison of the genotypes for the patient (`mev-pat-toy`) and wastewater (`mev-ww-toy`) samples. This structure allows for the immediate identification of shared or unique mutations across different surveillance streams.

#### Command Example: Viewing Variant Calls
To inspect the resulting calls and the sample-specific data columns without the extensive header information:

```bash
# View the variant calls and the sample data columns
grep -v "^##" mev_toy_variants.vcf | head -n 10
```

### The Bioinformatic Data Lifecycle

The transition from raw sequencing data to biological insights follows a structured progression through the file formats explored in this session:

* **FASTQ** files provide the raw nucleotide sequences and quality scores directly from the sequencing instrument.
* **FASTA** files provide the reference framework or "blueprint" against which the sample is compared.
* **BAM** files represent the evidence of alignment, showing exactly where raw reads match the reference genome.
* **BED** files define specific genomic regions of interest, allowing for targeted filtering or analysis of the alignment data.
* **VCF** files are the final product of the lifecycle, providing a standardized list of the biological differences and mutations identified in the sample.

## Post-Session Exercise: Visualizing Variants in IGV

While command-line tools like `samtools` and `bcftools` provide statistical summaries, visual inspection of alignments is a standard practice for validating variant calls. The **Integrative Genomics Viewer (IGV)** is a high-performance visualization tool for interactive exploration of large genomic datasets.

### Required Files for Export
To visualize the alignment locally, the following files must be downloaded from the GitHub Codespace environment. In the Codespace file explorer (left-hand sidebar), right-click each file and select **Download**.

| File Category | Filename | Description |
| :--- | :--- | :--- |
| **Reference** | `data/NC_001498.1.fasta` | The Measles virus reference genome. |
| **Index** | `data/NC_001498.1.fasta.fai` | The index for the reference genome. |
| **Alignment 1** | `data/mev-pat-toy.bam` | Alignment for the patient sample. |
| **Index 1** | `data/mev-pat-toy.bam.bai` | Index for the patient BAM. |
| **Alignment 2** | `data/mev-ww-toy.bam` | Alignment for the wastewater sample. |
| **Index 2** | `data/mev-ww-toy.bam.bai` | Index for the wastewater BAM. |



## Post-Session Exercise: Visualizing Variants in IGV-Web

While command-line tools provide statistical summaries, visual inspection of alignments is a standard practice for validating variant calls. The **IGV-Web** application is a browser-based version of the Integrative Genomics Viewer that allows for the interactive exploration of genomic data without local software installation.

### Required Files for Export
To visualize the data, the following files must be downloaded from the GitHub Codespace to the local workstation. In the Codespace file explorer (left-hand sidebar), right-click each file and select **Download**.

| File Category | Filename | Description |
| :--- | :--- | :--- |
| **Reference** | `data/NC_001498.1.fasta` | The Measles virus reference genome. |
| **Reference Index** | `data/NC_001498.1.fasta.fai` | Required for random access to the FASTA. |
| **Alignment 1** | `mev-pat-toy.bam` | Alignment for the patient sample. |
| **Alignment 1 Index**| `mev-pat-toy.bam.bai` | Required for loading the BAM file. |
| **Alignment 2** | `mev-ww-toy.bam` | Alignment for the wastewater sample. |
| **Alignment 2 Index**| `mev-ww-toy.bam.bai` | Required for loading the BAM file. |

### Visualizing Data in IGV-Web

1.  **Access the Application**: Navigate to [https://igv.org/app/](https://igv.org/app/).
2.  **Load the Custom Genome**: 
    * Select **Genome** > **Local File...**
    * Select both `NC_001498.1.fasta` and `NC_001498.1.fasta.fai` simultaneously.
3.  **Load the Alignment Tracks**:
    * Select **Tracks** > **Local File...**
    * Select both `mev-pat-toy.bam` and `mev-pat-toy.bam.bai` simultaneously.
    * Repeat this process to load the wastewater sample (`mev-ww-toy.bam` and its index).

### Points of Investigation
The following features are available for exploration within the web interface:

* **Coordinate Navigation**: The search bar at the top allows for navigation to specific coordinates. The Measles genome is relatively small (approx. 15.9kb), allowing for easy scrolling across the entire length.
* **Mismatches and SNPs**: Zoom in until individual bases are visible. Mismatches relative to the reference appear as colored letters (A, C, T, G) within the alignment tracks.
* **Coverage Track**: The bar chart at the top of each BAM track indicates sequencing depth. High-frequency variations will appear as colored bars within this coverage summary.
* **Wastewater Comparison**: Compare the alignment of the patient sample against the wastewater sample. Note if certain regions show higher variability or lower coverage in the environmental sample.

### Technical Note on Indices
IGV-Web requires the index files (`.fai` and `.bai`) to be selected at the same time as the primary data files. If the index is missing or not selected, the application will be unable to render the genomic data.