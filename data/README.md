# This readme describes how the toy datasets were created

## [2026-03-25 : Bioinformatic files](../2026-03-25/)
- NC_001498.1.fasta

Copied and pasted from https://www.ncbi.nlm.nih.gov/nuccore/NC_001498.1?report=fasta
- NC_001498.1.fasta.fai 
```bash
samtools faidx NC_001498.1.fasta
```

- targets.bed

Copied and pasted regions of interest.


- fastq files mev-{pat,ww}-toy_R{1,2}.fastq.gz
Files were originally downloaded from the SRA for accessions SRR37558655 (ww) and SRR36155251 (pat). 

```bash
# downloaded
fasterq-dump -A SRR37558655 --split-files
# aligned and mapped
minimap2 -ax sr NC_001498.1.fasta SRR37558655_1.fastq SRR37558655_2.fastq | \
    samtools view -bS - | samtools sort -o full_sorted.bam
# indexed
samtools index full_sorted.bam
# specific regions extracted
samtools view -b full_sorted.bam "NC_001498.1:108-1300" "NC_001498.1:7244-9097" > pool.bam

# Randomly select 400 read IDs from this pool
samtools view pool.bam | cut -f1 | uniq | shuf -n 400 > selected_names.txt

# Create the subset of the bam using those IDs
samtools view -N selected_names.txt -b pool.bam > training.bam
samtools index training.bam

# Create the "Training FASTQs" from that BAM
samtools fastq -1 data/mev-ww-toy_R1.fastq.gz -2 data/mev-ww-toy_R1.fastq.gz training.bam
```

- mev-pat-toy.sam

```bash
minimap2 -ax sr data/NC_001498.1.fasta \
    data/mev-pat-toy_R1.fastq.gz \
    data/mev-pat-toy_R2.fastq.gz > data/mev-pat-toy.sam

minimap2 -ax sr data/NC_001498.1.fasta \
    data/mev-ww-toy_R1.fastq.gz \
    data/mev-ww-toy_R2.fastq.gz > data/mev-ww-toy.sam

```

- mev_toy_variants.vcf
```bash
bcftools mpileup -f data/NC_001498.1.fasta \
    mev-pat-toy.bam \
    mev-ww-toy.bam | \
    bcftools call -mv -o data/mev_toy_variants.vcf
```

