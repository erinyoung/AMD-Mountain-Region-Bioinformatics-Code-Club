# Viral Genomics Workflows with Nextflow and Cecret

> **Codespaces Hardware Note:** If available, select a **4-core (8GB or 16GB RAM)** GitHub Codespaces instance for this session so Docker containers for Nextclade, MAFFT, and IQ-TREE have plenty of headroom.

## Session Overview

The primary objective of this 30-minute session is to introduce workflow management systems using **Nextflow** and run **Cecret** (`UPHL-BioNGS/Cecret`), a reference-based viral consensus and surveillance pipeline developed at the Utah Public Health Laboratory (UPHL).

By the end of this 30-minute code-along, participants will be able to:

* **Run containerized Nextflow workflows:** Launch Nextflow from a Docker image in GitHub Codespaces using a command-line alias without locally installing Java or Nextflow.
* **Analyze viral FASTA sequences with Cecret:** Execute species-specific sub-workflows (such as Nextclade clade assignment) on pre-assembled consensus FASTA files.
* **Perform phylogenetic relatedness analysis and resume runs:** Leverage Nextflow's `-resume` caching alongside Cecret's `--relatedness` workflow and understand how sample sheets scale the same pipeline to raw FASTQ sequencing reads.

## References

* [Nextflow Documentation](https://www.nextflow.io/docs/latest/)
* [UPHL-BioNGS/Cecret GitHub Repository](https://github.com/UPHL-BioNGS/Cecret) & [Cecret Wiki](https://github.com/UPHL-BioNGS/Cecret/wiki)
* Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. *Nat Biotechnol*. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820. PMID: 28398311.
* Aksamentov I, Roemer C, Hodcroft EB, Neher RA. Nextclade: clade assignment, mutation calling and quality control for viral genomes. *J Open Source Softw*. 2021;6(67):3773. doi: 10.21105/joss.03773.
* Minh BQ, Schmidt HA, Chernomor O, Schrempf D, Woodhams MD, von Haeseler A, Lanfear R. IQ-TREE 2: New Models and Efficient Methods for Phylogenetic Inference in the Genomic Era. *Mol Biol Evol*. 2020 May 1;37(5):1530-1534. doi: 10.1093/molbev/msaa015. PMID: 32011700; PMCID: PMC7182206.

## Background

### Why Workflow Managers (Nextflow)?

In previous sessions, we ran individual tools (think `samtools` or `kraken2`) one command at a time. In a public health laboratory processing dozens or hundreds of samples per sequencing run, chaining those steps manually becomes error-prone and hard to reproduce.

**Nextflow** is a workflow orchestration engine that solves three core problems:

1. **Containerized Execution (`-profile docker`):** Every step ("process") in a Nextflow pipeline runs inside its own dedicated Docker container (such as StaPH-B images), eliminating dependency conflicts across tools.
2. **Parallelization:** Nextflow automatically runs independent samples concurrently based on available CPU and memory resources.
3. **Checkpointing and Caching (`-resume`):** Nextflow tracks every task's inputs, script, and container hash inside a `work/` directory. If a run is interrupted or you add a downstream step, `-resume` skips completed tasks and only executes what is new or changed.

### What is Cecret?

**Cecret** (`UPHL-BioNGS/Cecret`) is a Nextflow pipeline designed for reference-based viral consensus genome generation, quality control, clade/lineage assignment, and phylogenetic relatedness.

While Cecret is most commonly used to turn raw paired-end or single-end FASTQ reads into consensus FASTA genomes (using BWA/Minimap2, iVar/SAMtools, FastQC, Kraken2, Pangolin, and Freyja), it also accepts **pre-assembled FASTA files** directly. Passing FASTA files skips read alignment and variant calling, allowing public health bioinformaticians to run clade typing, multiple sequence alignment, and phylogenetic tree building in minutes.

## Installing Nextflow

The URL for installing nextflow for your local resource can be found at https://docs.seqera.io/nextflow/install. 

Ensure that the environmental variable `NXF_HOME` is writable (i.e. a place where the user can make directories and save files).

```bash
export NXF_HOME="$HOME/nextflow_home"
```

Install nextflow

```
curl -s https://get.nextflow.io | bash
```

Verify that Nextflow runs Pull the latest version of `UPHL-BioNGS/Cecret`

```bash
nextflow -version
```

Pull the latest version of `UPHL-BioNGS/Cecret`:

```bash
nextflow pull UPHL-BioNGS/Cecret
```

Note: `Nextflow` has dependencies such as `Java`, so some installations are more challenging than others. 

`Nextflow` has a conda recipe and can also be installed with

```bash
conda install -c bioconda nextflow
```

`Nextflow` also has a docker image that can be used from dockerhub at `nextflow/nextflow:26.04.9`

To use this, remember to 
1. Mount a nextflow home directory
2. Mount the corresponding docker files to avoid unpredictable behavior of running docker in a docker container.

The command would look something like
```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD:/data" \
  -v "$HOME/.nextflow:$HOME/.nextflow" \
  -w "/data" \
  nextflow/nextflow:26.04.9 \
  # replace ... with the nextflow command (i.e. nextflow run UPHL-BioNGS/Cecret --help)
  ...
```


## Exploring the Input Data

The input consensus genomes for today's session are located in `data/dengue`:

```output
$ tree data/dengue/
data/dengue/
├── fastas
│   ├── OZ583412.1.fasta
│   ├── QB208681.1.fasta
│   ├── QB208724.1.fasta
│   ├── QB208737.1.fasta
│   ├── QB246908.1.fasta
│   └── QB298379.1.fasta
└── reference.fasta
```

We are going to pretend that the following fasta files are relevant samples.

```output
$ ls data/dengue/fastas
OZ583412.1.fasta  QB208681.1.fasta  QB208724.1.fasta  QB208737.1.fasta  QB246908.1.fasta  QB298379.1.fasta
```

Inspect the FASTA headers to view the sample identifiers:

```bash
head -n 1 data/dengue/fastas/*.fasta
```

## Running Cecret

### 1. Basic Consensus Classification

First, we will run Cecret on our directory of individual FASTA files. By default, Cecret assumes `--species sarscov2`. Because we are analyzing Dengue genomes here, we specify `--species dengue` and provide the appropriate Nextclade dataset (`nextstrain/dengue/all`).

```bash
nextflow run UPHL-BioNGS/Cecret \
  -profile uphl,docker \
  --fastas data/dengue/fastas/ \
  --species dengue \
  --nextclade_dataset 'nextstrain/dengue/all'
```

#### Parameter Breakdown

| Parameter | Purpose |
| :--- | :--- |
| `UPHL-BioNGS/Cecret` | Automatically fetches and runs the Cecret pipeline from GitHub. |
| `-profile uphl,docker` | Combines UPHL's configuration defaults (`uphl`) with Docker container execution (`docker`). |
| `--fastas data/dengue/fastas/` | Instructs Cecret to ingest pre-assembled single-entry FASTA files rather than raw FASTQ reads. |
| `--species dengue` | Switches Cecret from its default (`sarscov2`) to the Dengue sub-workflow configuration. |
| `--nextclade_dataset 'nextstrain/dengue/all'` | Specifies the Nextclade reference dataset used for serotype/lineage assignment and QC. |

### 2. Adding Phylogenetic Relatedness with `-resume`

Next, we will add `--relatedness` to generate a multiple sequence alignment, pairwise SNP distance matrix, and maximum-likelihood phylogenetic tree, rooted using Dengue virus 1 (`NC_001474.2`) as the outgroup.

Notice the `-resume` flag at the end: Nextflow recognizes that Nextclade already completed on these exact inputs and reuses the cached outputs instead of recomputing them.

```bash
nextflow run UPHL-BioNGS/Cecret \
  -profile uphl,docker \
  --fastas individual_fastas/ \
  --species dengue \
  --nextclade_dataset 'nextstrain/dengue/all' \
  --relatedness \
  --reference_genome reference.fasta \
  --iqtree_outgroup NC_001474.2 \
  -resume
```

#### Additional Parameter Breakdown

| Parameter | Purpose |
| :--- | :--- |
| `--relatedness` | Enables multiple sequence alignment (`mafft`/`nextclade`), pairwise SNP distances (`snp-dists` + `heatcluster`), and phylogenetics (`iqtree` + `phytreeviz`). |
| `--reference_genome reference.fasta` | Supplies the reference FASTA genome used for alignment and SNP comparison. |
| `--iqtree_outgroup NC_001474.2` | Roots the resulting IQ-TREE phylogeny using accession `NC_001474.2`. |
| `-resume` | Reuses cached work directory outputs for unchanged upstream tasks. |

### 3. Scaling to Raw Reads with a Sample Sheet (Reference Example)

When starting directly from sequencer output (paired-end FASTQ files) rather than pre-assembled FASTA files, Cecret takes a CSV sample sheet via `--sample_sheet`. Running full read alignment, primer trimming, and variant calling exceeds our 30-minute session window, so we will review the command structure without executing it:

```bash
nextflow run UPHL-BioNGS/Cecret \
  -profile uphl,docker \
  --sample_sheet 2026-11-19/sample_sheet.csv
```

A Cecret sample sheet uses the header `sample,fastq_1,fastq_2`:

```csv
sample,fastq_1,fastq_2
SRR13957123,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/023/SRR13957123/SRR13957123_1.fastq.gz,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/023/SRR13957123/SRR13957123_2.fastq.gz
SRR13957125,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/025/SRR13957125/SRR13957125_1.fastq.gz,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/025/SRR13957125/SRR13957125_2.fastq.gz
SRR13957170,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/070/SRR13957170/SRR13957170_1.fastq.gz,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/070/SRR13957170/SRR13957170_2.fastq.gz
SRR13957177,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/077/SRR13957177/SRR13957177_1.fastq.gz,ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR139/077/SRR13957177/SRR13957177_2.fastq.gz
```

Notice that `--species` is omitted in this example. Without `--species`, Cecret defaults to **SARS-CoV-2**, automatically running read trimming, alignment (`bwa`), primer trimming and consensus generation (`ivar`), clade/lineage typing (`nextclade` and `pangolin`), and mixed-lineage abundance estimation (`freyja`)—which is especially useful for **SARS-CoV-2 wastewater surveillance** samples containing multiple circulating lineages.

## Inspecting Cecret Outputs

By default, Cecret writes all organized outputs to the `cecret/` directory:

```bash
ls cecret/
```

Key files and directories to explore:

* **`cecret/cecret_results.csv` / `cecret_results.txt`**: Master summary table combining QC metrics, Nextclade clades/lineages, and coverage statistics across all samples.
* **`cecret/nextclade/`**: Detailed Nextclade mutation calls, clade assignments, and aligned sequences.
* **`cecret/snp-dists/` & `cecret/heatcluster/`**: Pairwise SNP distance matrix and clustered heatmap generated by `--relatedness`.
* **`cecret/iqtree/` & `cecret/phytreeviz/`**: Newick tree files (`.treefile`) and rendered phylogenetic tree visualizations.
* **`cecret/multiqc/multiqc_report.html`**: Interactive HTML summary report aggregating QC metrics across the entire run.

```bash
# View the combined summary table
column -t -s ',' cecret/cecret_results.csv
```