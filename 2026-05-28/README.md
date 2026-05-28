# Finding AMR Genes

## Session Overview

The primary objective of this 30-minute session is to understand that there are various database that can be used to identify Antimicrobial Resistant (AMR) genes and the basics of how to use and interpret these resources.

By the end of this 30-minute code-along, participants will be able to:

* Deploy containerized tools: Successfully run [StaPH-B's docker images](https://github.com/StaPH-B/docker-builds) ([ABRicate](https://hub.docker.com/r/staphb/abricate) and [AMRFinderPlus](https://hub.docker.com/r/staphb/ncbi-amrfinderplus)) using command-line aliases to streamline complex bioinformatics workflows.

* Compare search algorithms: Explain why nucleotide-based tools ([ABRicate](https://hub.docker.com/r/staphb/abricate)) and protein/HMM-based tools ([AMRFinderPlus](https://hub.docker.com/r/staphb/ncbi-amrfinderplus)) yield different results for the exact same bacterial genome.


## References
* Belay WY, Getachew M, Tegegne BA, Teffera ZH, Dagne A,   Zeleke TK, Abebe RB, Gedif AA, Fenta A, Yirdaw G, Tilahun A, Aschale Y. Mechanism of antibacterial resistance, strategies and next-generation antimicrobials to contain antimicrobial resistance: a review. Front Pharmacol. 2024 Aug 16;15:1444781. doi: 10.3389/fphar.2024.1444781. PMID: 39221153; PMCID: PMC11362070.
* Sherry NL, Lee JYH, Giulieri SG, Connor CH, Horan K, Lacey JA, Lane CR, Carter GP, Seemann T, Egli A, Stinear TP, Howden BP. Genomics for antimicrobial resistance-progress and future directions. Antimicrob Agents Chemother. 2025 May 7;69(5):e0108224. doi: 10.1128/aac.01082-24. Epub 2025 Apr 14. PMID: 40227048; PMCID: PMC12057382.
* Sati H, Carrara E, Savoldi A, Hansen P, Garlasco J, Campagnaro E, Boccia S, Castillo-Polo JA, Magrini E, Garcia-Vello P, Wool E, Gigante V, Duffy E, Cassini A, Huttner B, Pardo PR, Naghavi M, Mirzayev F, Zignol M, Cameron A, Tacconelli E; WHO Bacterial Priority Pathogens List Advisory Group. The WHO Bacterial Priority Pathogens List 2024: a prioritisation study to guide research, development, and public health strategies against a ntimicrobial resistance. Lancet Infect Dis. 2025 Sep;25(9):1033-1043. doi: 10.1016/S1473-3099(25)00118-5. Epub 2025 Apr 14. PMID: 40245910; PMCID: PMC12367593.
* Darby EM, Trampari E, Siasat P, Gaya MS, Alav I, Webber MA, Blair JMA. Molecular mechanisms of antibiotic resistance revisited. Nat Rev Microbiol. 2023 May;21(5):280-295. doi: 10.1038/s41579-022-00820-y. Epub 2022 Nov 21. Erratum in: Nat Rev Microbiol. 2024 Apr;22(4):255. doi: 10.1038/s41579-024-01014-4. PMID: 36411397.
* [abricate](https://github.com/tseemann/abricate)
* Feldgarden M, Brover V, Gonzalez-Escalona N, Frye JG, Haendiges J, Haft DH, Hoffmann M, Pettengill JB, Prasad AB, Tillman GE, Tyson GH, Klimke W. AMRFinderPlus and the Reference Gene Catalog facilitate examination of the genomic links among antimicrobial resistance, stress response, and virulence. Sci Rep. 2021 Jun 16;11(1):12728. doi: 10.1038/s41598-021-91456-0. PMID: 34135355; PMCID: PMC8208984. https://github.com/ncbi/amr
* Inda-Díaz, Juan Salvador, et al. "The Elusive Resistome: A Global Comparison Reveals Large Discrepancies Among Detection Pipelines." bioRxiv, 11 May 2026, https://doi.org/10.64898/2026.05.11.724158.

## Tool Installation
 
Nothing will be installed in this code club, instead we will utilize [StaPH-B's docker images](https://github.com/StaPH-B/docker-builds) for [ABRicate](https://hub.docker.com/r/staphb/abricate) and NCBI Antimicrobial Resistance Gene Finder ([AMRFinderPlus](https://hub.docker.com/r/staphb/ncbi-amrfinderplus)). 

We are going to set up an alias to run the docker commands. This allows us to avoid a massive Docker command every single time we want to run a tool. It's shortcut for command-line commands. Any generated alias will not be saved between GitHub CodeSpace sessions.

### Pulling ABRicate
```bash
docker pull staphb/abricate:1.2.0
alias abricate='docker run --rm -v "$(pwd):/data" -w /data staphb/abricate:1.2.0 abricate'
```

### Pulling AMRFinderPlus
```bash
docker pull staphb/ncbi-amrfinderplus:4.2.7-2026-03-24.1
alias amrfinder='docker run --rm -v "$(pwd):/data" -w /data staphb/ncbi-amrfinderplus:4.2.7-2026-03-24.1 amrfinder'
```

## Download some test files

We are going to download files for two organisms:
* _Klebsiella pneumoniae_: [GCA_040456195.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_040456195.1/)
* _Campylobacter jejuni_: [GCA_056635755.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_056635755.1/)

### Downloading the Klebsiella test file

```bash
# Download the zipped assembly file from NCBI
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/040/456/195/GCA_040456195.1_PDT002238574.1/GCA_040456195.1_PDT002238574.1_genomic.fna.gz

# Decompress the file so our tools can read it
gunzip GCA_040456195.1_PDT002238574.1_genomic.fna.gz

# Rename the file to something simple
mv GCA_040456195.1_PDT002238574.1_genomic.fna klebsiella_isolate.fna
```
### Downloading the Campylobacter test file
```bash
# Download the zipped assembly file from NCBI
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/056/635/755/GCA_056635755.1_PDT003170548.1/GCA_056635755.1_PDT003170548.1_genomic.fna.gz

# Decompress the file so our tools can read it
gunzip GCA_056635755.1_PDT003170548.1_genomic.fna.gz

# Rename the file to something simple
mv GCA_056635755.1_PDT003170548.1_genomic.fna campylobacter_isolate.fna
```

## Background

### The Molecular and Systemic Burden of AMR

The global dissemination of antimicrobial resistance (AMR) genes represents a critical inflection point in modern medicine, signifying a systemic erosion of the therapeutic window. From a molecular perspective, these genes facilitate a rapid, stochastic expansion of the bacterial [resistome](https://en.wikipedia.org/wiki/Resistome) across phylogenetic boundaries. For the epidemiologist, this manifests as an increased burden of morbidity and mortality, as common pathogens evolve into "superbugs" that defy standard-of-care protocols. For the laboratorian and bioinformatician, the challenge lies in the shifting landscape of diagnostic targets. Beyond the immediate clinical failure, the proliferation of these genetic markers undermines the safety of high-stakes interventions, including solid-organ transplantation, complex oncology regimens, and neonatal intensive care, effectively threatening to revert global health infrastructure to a pre-antibiotic paradigm where simple infections become fatal events.

### The Genotype vs. Phenotype Disconnect

A major limitation of bioinformatic AMR screening is that detecting an AMR gene (the genotype) does not guarantee the organism is actually resistant to the antibiotic in real life (the phenotype). Tools like ABRicate scan for matching DNA sequences, but they cannot indicate if that sequence is actually functioning. For example, a detected gene might lack a strong upstream promoter. Because of these biological variables, genomic AMR detection is an incredibly powerful early-warning and surveillance tool, but it is not a perfect replacement for traditional, wet-lab Antimicrobial Susceptibility Testing (AST) when making critical patient treatment decisions.

### AMR Genes can be found on chromosomes or plasmids

The topological distribution of AMR genes within the bacterial genome (including both the AMR genes located on chromosomes and on plasmids). Chromosomal markers typically underpin intrinsic resistance or emerge via vertical inheritance of point mutations in conserved loci. Plasmid-mediated AMR is driven by horizontal gene transfer (HGT), where promiscuous extra-chromosomal elements facilitate the rapid, inter-species spread of multi-drug resistant (MDR) cassettes.

### The Big Five Carbapenemases

There are a lot of genes implicated in resistance. In order to coordinate efforts a subset of genes are considered "higher" priority.

* [KPC](https://en.wikipedia.org/wiki/Beta-lactamase#KPC_(K._pneumoniae_carbapenemase)_(class_A))
* [NDM](https://en.wikipedia.org/wiki/New_Delhi_metallo-beta-lactamase_1)
* [VIM](https://en.wikipedia.org/wiki/Beta-lactamase#VIM_(Verona_integron-encoded_metallo-%CE%B2-lactamase)_(Class_B))
* IMP
* OXA-48-like
* GES (not actually one of the Big 5)

### Incomplete database of AMR gene databases for various bacteria and viruses

The following tables delineate a non-exhaustive selection of genomic databases and interpretive resources utilized for the identification of acquired resistance determinants and conferring polymorphisms across the bacterial and viral resistomes.

#### General Bacterial AMR Databases (Non-TB)

| Database | Full Name / Scope | Primary Use Case |
| :--- | :--- | :--- |
| **CARD** | Comprehensive Antibiotic Resistance Database | The gold standard for curated AMR ontology and predictive models (Strict vs. Loose hits). |
| **NDARO** | National Database of Antibiotic Resistant Organisms (NCBI) | Highly curated dataset powering AMRFinderPlus; required for NCBI submissions. |
| **ResFinder** | DTU Acquired Antimicrobial Resistance Genes | Rapid identification of genes acquired via horizontal gene transfer (HGT). |
| **ARG-ANNOT** | Antibiotic Resistance Gene-ANNOTation | Lightweight database optimized for local or desktop bioinformatic pipelines. |
| **MEGARes** | High-throughput AMR sequence database | Environmental and metagenomic studies; includes biocides and heavy metal resistance. |
| **BacMet** | Antibacterial Biocide and Metal Resistance Genes | Tracking resistance to industrial chemicals, heavy metals, and disinfectants. |
| **SARG** | Structured ARG database | Specialized for metagenomic profiling of environmental samples (e.g., wastewater). |
| **FARME** | Functional Antibiotic Resistant Metagenomic Element | Catalogs AMR genes discovered via functional metagenomics rather than homology. |
| **BV-BRC** | Bacterial and Viral Bioinformatics Resource Center | Aggregator mapping clinical phenotypes to genomic data (formerly PATRIC). |

#### Mycobacterium tuberculosis (TB) Databases
| Database | Full Name / Scope | Primary Use Case |
| :--- | :--- | :--- |
| **WHO Catalogue** | WHO TB Mutation Catalogue | Global authority for grading mutations as "Associated with Resistance," "Benign," or "Uncertain." |
| **ReSeqTB** | Relational Sequencing TB Data Platform | Collaborative platform linking genomic mutations to lab-verified clinical outcomes. |
| **TB-Profiler DB** | TB-Profiler Internal Database | Underlying library for the prominent command-line TB resistance profiling tool. |
| **Mykrobe DB** | Mykrobe Predictor Database | Utilizes k-mer based approaches for rapid identification of resistance mutations from raw reads. |
| **CRyPTIC** | Comprehensive Resistance Prediction for TB | Global dataset used to validate rare or emergent resistance-conferring mutations. |
| **PhyResSE** | TB Lineage and Resistance Server | Mapping mutations to both drug resistance and evolutionary lineage. |


#### Viral Resistance Databases

| Pathogen | Database | Primary Use Case |
| :--- | :--- | :--- |
| **Influenza** | GISAID / EpiFlu (FluSurver) | Global repository scanning for Tamiflu and other antiviral resistance markers. |
| **Influenza** | BV-BRC (formerly IRD) | Automated flagging of sequences with known phenotypic variants linked to resistance. |
| **Influenza** | NCBI Influenza Virus Resource | Centralizes GenBank data and utilizes the FLAN tool for mutation mapping. |
| **HIV** | Stanford HIVdb | The clinical standard for predicting resistance to Protease, Integrase, and RT inhibitors. |
| **HIV** | LANL HIV Sequence Database | Tracking global HIV evolution and associated resistance mutations. |
| **SARS-CoV-2** | Stanford CoV-RDB | Monitoring mutations conferring immune escape or resistance to antivirals (e.g., Paxlovid). |
| **SARS-CoV-2** | GISAID EpiCoV (CoVSurver) | Tracking Variants of Concern (VOCs) and treatment-evading mutations. |
| **HCV** | HCV-GLUE | Automated detection of Resistance-Associated Substitutions (RASs). |
| **Hepatitis B/C** | Geno2pheno | Predictive web suite for viral phenotypic resistance from genomic sequences. |
| **CMV** | MRC-University of Glasgow | Tracking mutations conferring resistance in Cytomegalovirus, critical for transplant patients. |

## Using ABRicate

[ABRicate](https://hub.docker.com/r/staphb/abricate) is a highly efficient bioinformatics tool designed to mass-screen assembled bacterial genomes for acquired antimicrobial resistance and virulence genes. It uses DNA-to-DNA comparison (BLASTN) to rapidly scan a sample's contigs against massive, curated public databases like NCBI, CARD, and ResFinder.

### Listing available databases

Use `abricate --list` To observe what databases are already installed in the ABRicate image.

```bash
abricate --list
```

The results should be something like the following:
```
DATABASE        SEQUENCES       DBTYPE  DATE
resfinder       3206    nucl    2026-Jan-8
card    6052    nucl    2026-Jan-8
ecoli_vf        2701    nucl    2026-Jan-8
vfdb    4592    nucl    2026-Jan-8
argannot        2224    nucl    2026-Jan-8
megares 6635    nucl    2026-Jan-8
victors 4545    nucl    2026-Jan-8
plasmidfinder   488     nucl    2026-Jan-8
bacmet2 746     prot    2026-Jan-8
ncbi    8035    nucl    2026-Jan-8
ecoh    597     nucl    2026-Jan-8
```

### Running ABRicate

```bash
# Run the tool and save the output to a TSV file
abricate --db ncbi *.fna > abricate_results.tsv

# View the results as a clean table
column -t -s $'\t' abricate_results.tsv
```

### Looking at the results

The results should look like this
```
#FILE	SEQUENCE	START	END	STRAND	GENE	COVERAGE	COVERAGE_MAP	GAPS	%COVERAGE	%IDENTITY	DATABASE	ACCESSION	PRODUCT	RESISTANCE
campylobacter_isolate.fna	ACCXAQ010000001.1	41064	41868	+	blaOXA-605	1-807/807	========/======	1/2	99.75	99.63	ncbi	NG_057542.1	OXA-61 family class D beta-lactamase OXA-605	BETA-LACTAM
campylobacter_isolate.fna	ACCXAQ010000031.1	1474	2278	+	blaOXA-605	1-807/807	========/======	1/2	99.75	99.63	ncbi	NG_057542.1	OXA-61 family class D beta-lactamase OXA-605	BETA-LACTAM
klebsiella_isolate.fna	ABTGUD010000002.1	292052	292912	+	blaSHV-110	1-861/861	===============	0/0	100.00	99.88	ncbi	NG_050001.1	class A beta-lactamase SHV-110	BETA-LACTAM
klebsiella_isolate.fna	ABTGUD010000005.1	35814	36989	+	oqxA11	1-1176/1176	===============	0/0	100.00	99.49	ncbi	NG_050419.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA11	PHENICOL;QUINOLONE
klebsiella_isolate.fna	ABTGUD010000005.1	37013	40165	+	oqxB32	1-3153/3153	===============	0/0	100.00	99.43	ncbi	NG_050452.1	multidrug efflux RND transporter permease subunit OqxB32	PHENICOL;QUINOLONE
klebsiella_isolate.fna	ABTGUD010000008.1	346181	346600	-	fosA5_fam	1-420/420	===============	0/0	100.00	96.43	ncbi	NG_047881.1	FosA5 family fosfomycin resistance glutathione transferase	FOSFOMYCIN
klebsiella_isolate.fna	ABTGUD010000022.1	3078	3959	+	blaKPC-3	1-882/882	===============	0/0	100.00	100.00	ncbi	NG_049257.1	carbapenem-hydrolyzing class A beta-lactamase KPC-3	CARBAPENEM
klebsiella_isolate.fna	ABTGUD010000023.1	391	1266	-	blaCTX-M-15	1-876/876	===============	0/0	100.00	100.00	ncbi	NG_048935.1	extended-spectrum class A beta-lactamase CTX-M-15	CEPHALOSPORIN
klebsiella_isolate.fna	ABTGUD010000023.1	4088	4948	+	blaTEM-1	1-861/861	===============	0/0	100.00	100.00	ncbi	NG_050145.1	broad-spectrum class A beta-lactamase TEM-1	BETA-LACTAM
klebsiella_isolate.fna	ABTGUD010000023.1	5669	6505	-	aph(6)-Id	1-837/837	===============	0/0	100.00	100.00	ncbi	NG_047464.1	aminoglycoside O-phosphotransferase APH(6)-Id	STREPTOMYCIN
klebsiella_isolate.fna	ABTGUD010000023.1	6505	7307	-	aph(3'')-Ib	2-804/804	===============	0/0	99.88	99.88	ncbi	NG_047413.1	aminoglycoside O-phosphotransferase APH(3'')-Ib	STREPTOMYCIN
klebsiella_isolate.fna	ABTGUD010000023.1	7369	8184	-	sul2	1-816/816	===============	0/0	100.00	100.00	ncbi	NG_051852.1	sulfonamide-resistant dihydropteroate synthase Sul2	SULFONAMIDE
klebsiella_isolate.fna	ABTGUD010000024.1	818	1462	-	qnrB1	1-645/645	===============	0/0	100.00	100.00	ncbi	NG_050469.1	quinolone resistance pentapeptide repeat protein QnrB1	QUINOLONE
klebsiella_isolate.fna	ABTGUD010000025.1	4601	5074	-	dfrA14	1-474/474	===============	0/0	100.00	100.00	ncbi	NG_056035.1	trimethoprim-resistant dihydrofolate reductase DfrA14	TRIMETHOPRIM
klebsiella_isolate.fna	ABTGUD010000032.1	1695	2555	-	aac(3)-IIe	1-861/861	===============	0/0	100.00	99.77	ncbi	NG_047244.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	GENTAMICIN
klebsiella_isolate.fna	ABTGUD010000034.1	578	1408	-	blaOXA-1	1-831/831	===============	0/0	100.00	100.00	ncbi	NG_049392.1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	CEPHALOSPORIN
klebsiella_isolate.fna	ABTGUD010000034.1	1539	2093	-	aac(6')-Ib-D181Y	1-555/555	===============	0/0	100.00	99.82	ncbi	NG_067946.1	AAC(6')-Ib family aminoglycoside 6'-N-acetyltransferase	AMIKACIN;KANAMYCIN;TOBRAMYCIN
klebsiella_isolate.fna	ABTGUD010000050.1	3119	4000	+	blaKPC-3	1-882/882	===============	0/0	100.00	100.00	ncbi	NG_049257.1	carbapenem-hydrolyzing class A beta-lactamase KPC-3	CARBAPENEM
klebsiella_isolate.fna	ABTGUD010000051.1	7111	8286	+	oqxA11	1-1176/1176	===============	0/0	100.00	99.49	ncbi	NG_050419.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA11	PHENICOL;QUINOLONE
klebsiella_isolate.fna	ABTGUD010000051.1	8310	11462	+	oqxB32	1-3153/3153	===============	0/0	100.00	99.43	ncbi	NG_050452.1	multidrug efflux RND transporter permease subunit OqxB32	PHENICOL;QUINOLONE
klebsiella_isolate.fna	ABTGUD010000053.1	216	635	+	fosA5_fam	1-420/420	===============	0/0	100.00	96.43	ncbi	NG_047881.1	FosA5 family fosfomycin resistance glutathione transferase	FOSFOMYCIN
klebsiella_isolate.fna	ABTGUD010000054.1	6582	7226	+	qnrB1	1-645/645	===============	0/0	100.00	100.00	ncbi	NG_050469.1	quinolone resistance pentapeptide repeat protein QnrB1	QUINOLONE
klebsiella_isolate.fna	ABTGUD010000056.1	676	1536	+	blaSHV-110	1-861/861	===============	0/0	100.00	99.88	ncbi	NG_050001.1	class A beta-lactamase SHV-110	BETA-LACTAM
klebsiella_isolate.fna	ABTGUD010000057.1	463	1278	+	sul2	1-816/816	===============	0/0	100.00	100.00	ncbi	NG_051852.1	sulfonamide-resistant dihydropteroate synthase Sul2	SULFONAMIDE
klebsiella_isolate.fna	ABTGUD010000057.1	1340	2142	+	aph(3'')-Ib	2-804/804	===============	0/0	99.88	99.88	ncbi	NG_047413.1	aminoglycoside O-phosphotransferase APH(3'')-Ib	STREPTOMYCIN
klebsiella_isolate.fna	ABTGUD010000057.1	2142	2978	+	aph(6)-Id	1-837/837	===============	0/0	100.00	100.00	ncbi	NG_047464.1	aminoglycoside O-phosphotransferase APH(6)-Id	STREPTOMYCIN
klebsiella_isolate.fna	ABTGUD010000058.1	1745	2620	+	blaCTX-M-15	1-876/876	===============	0/0	100.00	100.00	ncbi	NG_048935.1	extended-spectrum class A beta-lactamase CTX-M-15	CEPHALOSPORIN
klebsiella_isolate.fna	ABTGUD010000059.1	1690	2163	+	dfrA14	1-474/474	===============	0/0	100.00	100.00	ncbi	NG_056035.1	trimethoprim-resistant dihydrofolate reductase DfrA14	TRIMETHOPRIM
klebsiella_isolate.fna	ABTGUD010000060.1	84	944	+	aac(3)-IIe	1-861/861	===============	0/0	100.00	99.77	ncbi	NG_047244.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	GENTAMICIN
klebsiella_isolate.fna	ABTGUD010000061.1	84	944	+	aac(3)-IIe	1-861/861	===============	0/0	100.00	99.30	ncbi	NG_047244.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	GENTAMICIN
klebsiella_isolate.fna	ABTGUD010000062.1	84	944	+	aac(3)-IIe	1-861/861	===============	0/0	100.00	99.42	ncbi	NG_047244.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	GENTAMICIN
klebsiella_isolate.fna	ABTGUD010000063.1	130	684	+	aac(6')-Ib-D181Y	1-555/555	===============	0/0	100.00	99.82	ncbi	NG_067946.1	AAC(6')-Ib family aminoglycoside 6'-N-acetyltransferase	AMIKACIN;KANAMYCIN;TOBRAMYCIN
klebsiella_isolate.fna	ABTGUD010000063.1	815	1645	+	blaOXA-1	1-831/831	===============	0/0	100.00	100.00	ncbi	NG_049392.1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	CEPHALOSPORIN
klebsiella_isolate.fna	ABTGUD010000064.1	1025	1885	+	blaTEM-1	1-861/861	===============	0/0	100.00	100.00	ncbi	NG_050145.1	broad-spectrum class A beta-lactamase TEM-1	BETA-LACTAM
```

#### What the columns are

The tabular output enables a granular assessment of the genomic context and confidence intervals for each identified locus:

* SEQUENCE / START / END: Specify the topological coordinates of the hit within the assembly. 
* GENE / PRODUCT: Define the specific allelic variant and its associated biochemical function.
* %COVERAGE / COVERAGE_MAP: Represent the proportion of the reference gene identified in the query sequence. A 100% value signifies a full-length coding sequence. Lower values may indicate truncated alleles or assembly discontinuities at gene boundaries.
* %IDENTITY: The percentage of identical nucleotides across the alignment. High identity (>98%) suggests a high-confidence ortholog, while lower values may indicate novel allelic variants or sequencing artifacts.
* RESISTANCE: The predicted phenotypic resistance profile associated with the identified genotype.

#### Interpretation

The _Campylobacter jejuni_ harbors bla_OXA-605, an OXA-61 family Class D beta-lactamase. The detection of this locus on two distinct sequences (ACCXAQ010000001.1 and ACCXAQ010000031.1) suggests either gene duplication or the presence of multiple copies across the accessory genome.

The _Klebsiella pneumoniae_ indicates a critical, highly alarming multi-drug resistant (MDR) and carbapenem-resistant genotype. Crucially, it harbors blaKPC-3, a major public health priority marker confirming carbapenem resistance. Additionally, it displays an extensive resistance cassette targeting cephalosporins (blaCTX-M-15, blaOXA-1), fluoroquinolones/phenicols (oqxAB, qnrB1), aminoglycosides (aac(3)-IIe, aac(6')-Ib-D181Y), fosfomycin (fosA5_fam), sulfonamides (sul2), and trimethoprim (dfrA14).

## Using AMRFinderPlus

Developed by the NCBI, [AMRFinderPlus](https://hub.docker.com/r/staphb/ncbi-amrfinderplus) is a highly sophisticated tool that goes a step beyond simple DNA matching. Instead of just looking for matching nucleotide sequences, it translates genomic data into proteins and uses advanced Hidden Markov Models (HMMs) to identify resistance mechanisms. This makes it incredibly powerful because it can detect both acquired foreign genes (just like Abricate) and chromosomal point mutations.

### Listing available organisms

AMRFinderPlus has the power to identify point mutations, but it resistricts this option to certain organisms. To get those results, use the `--organism` flag.


```bash
amrfinder --list_organisms
```

The output from this should be something like the following:

```
Running: amrfinder --list_organisms
The number of threads cannot be greater than 2 on this computer
The current number of threads is 4, reducing to 2
Software directory: /amrfinder/
Software version: 4.2.7
Database directory: /amrfinder/data/2026-03-24.1
Database version: 2026-03-24.1
amrfinder took 0 seconds to complete

Available --organism options: Acinetobacter_baumannii, Bordetella_pertussis, Burkholderia_cepacia, Burkholderia_mallei, Burkholderia_pseudomallei, Campylobacter, Citrobacter_freundii, Clostridioides_difficile, Corynebacterium_diphtheriae, Enterobacter_asburiae, Enterobacter_cloacae, Enterococcus_faecalis, Enterococcus_faecium, Escherichia, Haemophilus_influenzae, Helicobacter_pylori, Klebsiella_oxytoca, Klebsiella_pneumoniae, Neisseria_gonorrhoeae, Neisseria_meningitidis, Pseudomonas_aeruginosa, Salmonella, Serratia_marcescens, Staphylococcus_aureus, Staphylococcus_epidermidis, Staphylococcus_pseudintermedius, Streptococcus_agalactiae, Streptococcus_pneumoniae, Streptococcus_pyogenes, Vibrio_cholerae, Vibrio_parahaemolyticus, Vibrio_vulnificus
```

We are going to use the "Campylobacter" and "Klebsiella_pneumoniae" on our respective samples.

### Running on the Klebsiella test file

```bash
# Run the tool and specify the organism type
amrfinder -n klebsiella_isolate.fna -O Klebsiella_pneumoniae --plus > klebsiella_amrfinder_results.tsv

# View the results
column -t -s $'\t' klebsiella_amrfinder_results.tsv
```

The results should look like this

```
Protein id	Contig id	Start	Stop	Strand	Element symbol	Element name	Scope	Type	Subtype	Class	Subclass	Method	Target length	Reference sequence length	% Coverage of reference	% Identity to reference	Alignment length	Closest reference accession	Closest reference name	HMM accession	HMM description
NA	ABTGUD010000002.1	292052	292909	+	blaSHV-27	broad-spectrum class A beta-lactamase SHV-27	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	286	286	100.00	100.00	286	WP_023282555.1	broad-spectrum class A beta-lactamase SHV-27	NA	NA
NA	ABTGUD010000005.1	35814	36986	+	oqxA	multidrug efflux RND transporter periplasmic adaptor subunit OqxA	core	AMR	AMR	NITROFURAN/PHENICOL/QUINOLONE/TETRACYCLINE	NITROFURANTOIN/PHENICOL/QUINOLONE/TIGECYCLINE	BLASTX	391	391	100.00	99.74	391	WP_004212918.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA11	NA	NA
NA	ABTGUD010000005.1	37013	40162	+	oqxB	multidrug efflux RND transporter permease subunit OqxB	core	AMR	AMR	NITROFURAN/PHENICOL/QUINOLONE/TETRACYCLINE	NITROFURANTOIN/PHENICOL/QUINOLONE/TIGECYCLINE	BLASTX	1050	1050	100.00	99.90	1050	WP_004149399.1	multidrug efflux RND transporter permease subunit OqxB19	NA	NA
NA	ABTGUD010000008.1	346184	346600	-	fosA	FosA5 family fosfomycin resistance glutathione transferase	core	AMR	AMR	FOSFOMYCIN	FOSFOMYCIN	BLASTX	139	139	100.00	99.28	139	WP_114473955.1	fosfomycin resistance glutathione transferase FosA9	NA	NA
NA	ABTGUD010000012.1	79844	81025	-	emrD	multidrug efflux MFS transporter EmrD	plus	AMR	AMR	EFFLUX	EFFLUX	BLASTX	394	394	100.00	99.75	394	ACN65732.1	multidrug efflux MFS transporter EmrD	NA	NA
NA	ABTGUD010000013.1	59177	60076	+	fieF	CDF family cation-efflux transporter FieF	plus	STRESS	METAL	NA	NA	BLASTX	300	300	100.00	99.67	300	BAB89353.1	CDF family cation-efflux transporter FieF	NA	NA
NA	ABTGUD010000017.1	904	1332	-	silE	silver-binding protein SilE	plus	STRESS	METAL	SILVER	SILVER	BLASTX	143	143	100.00	91.61	143	AAD11743.1	silver-binding protein SilE	NA	NA
NA	ABTGUD010000017.1	1586	3058	-	silS	copper/silver sensor histidine kinase SilS	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	EXACTX	491	491	100.00	100.00	491	SPD96882.1	copper/silver sensor histidine kinase SilS	NA	NA
NA	ABTGUD010000017.1	3054	3731	-	silR	copper/silver response regulator transcription factor SilR	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	EXACTX	226	226	100.00	100.00	226	SPD96883.1	copper/silver response regulator transcription factor SilR	NA	NA
NA	ABTGUD010000017.1	3921	5303	+	silC	Cu(+)/Ag(+) efflux RND transporter outer membrane channel SilC	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	EXACTX	461	461	100.00	100.00	461	SPD96884.1	Cu(+)/Ag(+) efflux RND transporter outer membrane channel SilC	NA	NA
NA	ABTGUD010000017.1	5335	5685	+	silF	Cu(+)/Ag(+) efflux RND transporter periplasmic metallochaperone SilF	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	117	117	100.00	99.15	117	KGL71342.1	Cu(+)/Ag(+) efflux RND transporter periplasmic metallochaperone SilF	NA	NA
NA	ABTGUD010000017.1	5802	7091	+	silB	Cu(+)/Ag(+) efflux RND transporter periplasmic adaptor subunit SilB	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	430	430	100.00	97.91	430	AAD11748.1	Cu(+)/Ag(+) efflux RND transporter periplasmic adaptor subunit SilB	NA	NA
NA	ABTGUD010000017.1	7105	10248	+	silA	Cu(+)/Ag(+) efflux RND transporter permease subunit SilA	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	1048	1048	100.00	98.85	1048	AAD11749.1	Cu(+)/Ag(+) efflux RND transporter permease subunit SilA	NA	NA
NA	ABTGUD010000017.1	10884	13355	+	silP	Ag(+)-translocating P-type ATPase SilP	plus	STRESS	METAL	SILVER	SILVER	BLASTX	824	824	99.64	94.18	825	AAD11750.1	Ag(+)-translocating P-type ATPase SilP	NA	NA
NA	ABTGUD010000017.1	15339	17153	+	pcoA	multicopper oxidase PcoA	plus	STRESS	METAL	COPPER	COPPER	EXACTX	605	605	100.00	100.00	605	CAA58525.1	multicopper oxidase PcoA	NA	NA
NA	ABTGUD010000017.1	17162	18049	+	pcoB	copper-binding protein PcoB	plus	STRESS	METAL	COPPER	COPPER	EXACTX	296	296	100.00	100.00	296	CAA58526.1	copper-binding protein PcoB	NA	NA
NA	ABTGUD010000017.1	18092	18469	+	pcoC	copper resistance system metallochaperone PcoC	plus	STRESS	METAL	COPPER	COPPER	EXACTX	126	126	100.00	100.00	126	CAA58527.1	copper resistance system metallochaperone PcoC	NA	NA
NA	ABTGUD010000017.1	18477	19403	+	pcoD	copper resistance inner membrane protein PcoD	plus	STRESS	METAL	COPPER	COPPER	BLASTX	309	309	100.00	99.68	309	CAA58528.1	copper resistance inner membrane protein PcoD	NA	NA
NA	ABTGUD010000017.1	19461	20138	+	pcoR	copper response regulator transcription factor PcoR	plus	STRESS	METAL	COPPER	COPPER	EXACTX	226	226	100.00	100.00	226	CAA58529.1	copper response regulator transcription factor PcoR	NA	NA
NA	ABTGUD010000017.1	20138	21535	+	pcoS	copper resistance membrane spanning protein PcoS	plus	STRESS	METAL	COPPER	COPPER	BLASTX	466	466	100.00	99.14	466	CAA58530.1	copper resistance membrane spanning protein PcoS	NA	NA
NA	ABTGUD010000017.1	21755	22186	+	pcoE	copper resistance system metallochaperone PcoE	plus	STRESS	METAL	COPPER	COPPER	BLASTX	144	144	100.00	94.44	144	CAA58532.1	copper resistance system metallochaperone PcoE	NA	NA
NA	ABTGUD010000017.1	30228	30650	-	arsC	glutaredoxin-dependent arsenate reductase	plus	STRESS	METAL	ARSENIC	ARSENATE	EXACTX	141	141	100.00	100.00	141	BAA24824.1	glutaredoxin-dependent arsenate reductase	NA	NA
NA	ABTGUD010000017.1	30666	31952	-	arsB	arsenite efflux transporter membrane subunit ArsB	plus	STRESS	METAL	ARSENIC	ARSENITE	EXACTX	429	429	100.00	100.00	429	BAA24823.1	arsenite efflux transporter membrane subunit ArsB	NA	NA
NA	ABTGUD010000017.1	32003	33751	-	arsA	arsenite efflux transporter ATPase subunit ArsA	plus	STRESS	METAL	ARSENIC	ARSENITE	EXACTX	583	583	100.00	100.00	583	BAA24822.1	arsenite efflux transporter ATPase subunit ArsA	NA	NA
NA	ABTGUD010000017.1	33772	34131	-	arsD	arsenite efflux transporter metallochaperone ArsD	plus	STRESS	METAL	ARSENIC	ARSENITE	BLASTX	120	120	100.00	91.67	120	AAB09625.1	arsenite efflux transporter metallochaperone ArsD	NA	NA
NA	ABTGUD010000017.1	34184	34531	-	arsR	As(III)-sensing metalloregulatory transcriptional repressor ArsR	plus	STRESS	METAL	ARSENIC	ARSENIC	EXACTX	116	116	100.00	100.00	116	AET17094.1	As(III)-sensing metalloregulatory transcriptional repressor ArsR	NA	NA
NA	ABTGUD010000017.1	44073	46859	-	clpK	heat shock survival AAA family ATPase ClpK	plus	STRESS	HEAT	NA	NA	BLASTX	929	949	97.89	99.25	929	ASF80763.1	heat shock survival AAA family ATPase ClpK	NA	NA
NA	ABTGUD010000017.1	46986	47552	-	hsp20	small heat shock protein sHSP20	plus	STRESS	HEAT	NA	NA	EXACTX	189	189	100.00	100.00	189	CDY80020.1	small heat shock protein sHSP20	NA	NA
NA	ABTGUD010000022.1	3078	3956	+	blaKPC-3	carbapenem-hydrolyzing class A beta-lactamase KPC-3	core	AMR	AMR	BETA-LACTAM	CARBAPENEM	ALLELEX	293	293	100.00	100.00	293	WP_004152396.1	carbapenem-hydrolyzing class A beta-lactamase KPC-3	NA	NA
NA	ABTGUD010000023.1	394	1266	-	blaCTX-M-15	extended-spectrum class A beta-lactamase CTX-M-15	core	AMR	AMR	BETA-LACTAM	CEPHALOSPORIN	ALLELEX	291	291	100.00	100.00	291	WP_000239590.1	extended-spectrum class A beta-lactamase CTX-M-15	NA	NA
NA	ABTGUD010000023.1	4088	4945	+	blaTEM-1	broad-spectrum class A beta-lactamase TEM-1	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	286	286	100.00	100.00	286	WP_000027057.1	broad-spectrum class A beta-lactamase TEM-1	NA	NA
NA	ABTGUD010000023.1	5672	6505	-	aph(6)-Id	aminoglycoside O-phosphotransferase APH(6)-Id	core	AMR	AMR	AMINOGLYCOSIDE	STREPTOMYCIN	EXACTX	278	278	100.00	100.00	278	WP_000480968.1	aminoglycoside O-phosphotransferase APH(6)-Id	NA	NA
NA	ABTGUD010000023.1	6508	7308	-	aph(3'')-Ib	aminoglycoside O-phosphotransferase APH(3'')-Ib	core	AMR	AMR	AMINOGLYCOSIDE	STREPTOMYCIN	EXACTX	267	267	100.00	100.00	267	WP_001082319.1	aminoglycoside O-phosphotransferase APH(3'')-Ib	NA	NA
NA	ABTGUD010000023.1	7372	8184	-	sul2	sulfonamide-resistant dihydropteroate synthase Sul2	core	AMR	AMR	SULFONAMIDE	SULFONAMIDE	EXACTX	271	271	100.00	100.00	271	WP_001043260.1	sulfonamide-resistant dihydropteroate synthase Sul2	NA	NA
NA	ABTGUD010000024.1	821	1462	-	qnrB1	quinolone resistance pentapeptide repeat protein QnrB1	core	AMR	AMR	QUINOLONE	QUINOLONE	ALLELEX	214	214	100.00	100.00	214	WP_014386481.1	quinolone resistance pentapeptide repeat protein QnrB1	NA	NA
NA	ABTGUD010000025.1	4604	5074	-	dfrA14	trimethoprim-resistant dihydrofolate reductase DfrA14	core	AMR	AMR	TRIMETHOPRIM	TRIMETHOPRIM	EXACTX	157	157	100.00	100.00	157	WP_004201280.1	trimethoprim-resistant dihydrofolate reductase DfrA14	NA	NA
NA	ABTGUD010000032.1	1698	2555	-	aac(3)-IIe	aminoglycoside N-acetyltransferase AAC(3)-IIe	core	AMR	AMR	AMINOGLYCOSIDE	GENTAMICIN	EXACTX	286	286	100.00	100.00	286	WP_000557452.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	NA	NA
NA	ABTGUD010000034.1	3	440	-	catB3	type B-3 chloramphenicol O-acetyltransferase CatB3	core	AMR	AMR	PHENICOL	CHLORAMPHENICOL	PARTIAL_CONTIG_ENDX	146	210	69.52	100.00	146	WP_000186237.1	type B-3 chloramphenicol O-acetyltransferase CatB3	NA	NA
NA	ABTGUD010000034.1	581	1408	-	blaOXA-1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	core	AMR	AMR	BETA-LACTAM	CEPHALOSPORIN	ALLELEX	276	276	100.00	100.00	276	WP_001334766.1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	NA	NA
NA	ABTGUD010000034.1	1542	2093	-	aac(6')-Ib-cr5	fluoroquinolone-acetylating aminoglycoside 6'-N-acetyltransferase AAC(6')-Ib-cr5	core	AMR	AMR	AMINOGLYCOSIDE/QUINOLONE	AMIKACIN/KANAMYCIN/QUINOLONE/TOBRAMYCIN	ALLELEX	184	184	100.00	100.00	184	WP_063840321.1	fluoroquinolone-acetylating aminoglycoside 6'-N-acetyltransferase AAC(6')-Ib-cr5	NA	NA
NA	ABTGUD010000050.1	3119	3997	+	blaKPC-3	carbapenem-hydrolyzing class A beta-lactamase KPC-3	core	AMR	AMR	BETA-LACTAM	CARBAPENEM	ALLELEX	293	293	100.00	100.00	293	WP_004152396.1	carbapenem-hydrolyzing class A beta-lactamase KPC-3	NA	NA
NA	ABTGUD010000051.1	7111	8283	+	oqxA	multidrug efflux RND transporter periplasmic adaptor subunit OqxA	core	AMR	AMR	NITROFURAN/PHENICOL/QUINOLONE/TETRACYCLINE	NITROFURANTOIN/PHENICOL/QUINOLONE/TIGECYCLINE	BLASTX	391	391	100.00	99.74	391	WP_004212918.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA11	NA	NA
NA	ABTGUD010000051.1	8310	11459	+	oqxB	multidrug efflux RND transporter permease subunit OqxB	core	AMR	AMR	NITROFURAN/PHENICOL/QUINOLONE/TETRACYCLINE	NITROFURANTOIN/PHENICOL/QUINOLONE/TIGECYCLINE	BLASTX	1050	1050	100.00	99.90	1050	WP_004149399.1	multidrug efflux RND transporter permease subunit OqxB19	NA	NA
NA	ABTGUD010000053.1	216	632	+	fosA	FosA5 family fosfomycin resistance glutathione transferase	core	AMR	AMR	FOSFOMYCIN	FOSFOMYCIN	BLASTX	139	139	100.00	99.28	139	WP_114473955.1	fosfomycin resistance glutathione transferase FosA9	NA	NA
NA	ABTGUD010000054.1	6582	7223	+	qnrB1	quinolone resistance pentapeptide repeat protein QnrB1	core	AMR	AMR	QUINOLONE	QUINOLONE	ALLELEX	214	214	100.00	100.00	214	WP_014386481.1	quinolone resistance pentapeptide repeat protein QnrB1	NA	NA
NA	ABTGUD010000056.1	676	1533	+	blaSHV-27	broad-spectrum class A beta-lactamase SHV-27	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	286	286	100.00	100.00	286	WP_023282555.1	broad-spectrum class A beta-lactamase SHV-27	NA	NA
NA	ABTGUD010000057.1	463	1275	+	sul2	sulfonamide-resistant dihydropteroate synthase Sul2	core	AMR	AMR	SULFONAMIDE	SULFONAMIDE	EXACTX	271	271	100.00	100.00	271	WP_001043260.1	sulfonamide-resistant dihydropteroate synthase Sul2	NA	NA
NA	ABTGUD010000057.1	1339	2139	+	aph(3'')-Ib	aminoglycoside O-phosphotransferase APH(3'')-Ib	core	AMR	AMR	AMINOGLYCOSIDE	STREPTOMYCIN	EXACTX	267	267	100.00	100.00	267	WP_001082319.1	aminoglycoside O-phosphotransferase APH(3'')-Ib	NA	NA
NA	ABTGUD010000057.1	2142	2975	+	aph(6)-Id	aminoglycoside O-phosphotransferase APH(6)-Id	core	AMR	AMR	AMINOGLYCOSIDE	STREPTOMYCIN	EXACTX	278	278	100.00	100.00	278	WP_000480968.1	aminoglycoside O-phosphotransferase APH(6)-Id	NA	NA
NA	ABTGUD010000058.1	1745	2617	+	blaCTX-M-15	extended-spectrum class A beta-lactamase CTX-M-15	core	AMR	AMR	BETA-LACTAM	CEPHALOSPORIN	ALLELEX	291	291	100.00	100.00	291	WP_000239590.1	extended-spectrum class A beta-lactamase CTX-M-15	NA	NA
NA	ABTGUD010000059.1	1690	2160	+	dfrA14	trimethoprim-resistant dihydrofolate reductase DfrA14	core	AMR	AMR	TRIMETHOPRIM	TRIMETHOPRIM	EXACTX	157	157	100.00	100.00	157	WP_004201280.1	trimethoprim-resistant dihydrofolate reductase DfrA14	NA	NA
NA	ABTGUD010000060.1	84	941	+	aac(3)-IIe	aminoglycoside N-acetyltransferase AAC(3)-IIe	core	AMR	AMR	AMINOGLYCOSIDE	GENTAMICIN	EXACTX	286	286	100.00	100.00	286	WP_000557452.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	NA	NA
NA	ABTGUD010000061.1	84	941	+	aac(3)-IIe	aminoglycoside N-acetyltransferase AAC(3)-IIe	core	AMR	AMR	AMINOGLYCOSIDE	GENTAMICIN	BLASTX	286	286	100.00	98.95	286	WP_000557452.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	NA	NA
NA	ABTGUD010000062.1	84	941	+	aac(3)-IIe	aminoglycoside N-acetyltransferase AAC(3)-IIe	core	AMR	AMR	AMINOGLYCOSIDE	GENTAMICIN	BLASTX	286	286	100.00	99.30	286	WP_000557452.1	aminoglycoside N-acetyltransferase AAC(3)-IIe	NA	NA
NA	ABTGUD010000063.1	130	681	+	aac(6')-Ib-cr5	fluoroquinolone-acetylating aminoglycoside 6'-N-acetyltransferase AAC(6')-Ib-cr5	core	AMR	AMR	AMINOGLYCOSIDE/QUINOLONE	AMIKACIN/KANAMYCIN/QUINOLONE/TOBRAMYCIN	ALLELEX	184	184	100.00	100.00	184	WP_063840321.1	fluoroquinolone-acetylating aminoglycoside 6'-N-acetyltransferase AAC(6')-Ib-cr5	NA	NA
NA	ABTGUD010000063.1	815	1642	+	blaOXA-1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	core	AMR	AMR	BETA-LACTAM	CEPHALOSPORIN	ALLELEX	276	276	100.00	100.00	276	WP_001334766.1	oxacillin-hydrolyzing class D beta-lactamase OXA-1	NA	NA
NA	ABTGUD010000063.1	1783	2223	+	catB3	type B-3 chloramphenicol O-acetyltransferase CatB3	core	AMR	AMR	PHENICOL	CHLORAMPHENICOL	PARTIALX	147	210	70.00	100.00	147	WP_000186237.1	type B-3 chloramphenicol O-acetyltransferase CatB3	NA	NA
NA	ABTGUD010000064.1	1025	1882	+	blaTEM-1	broad-spectrum class A beta-lactamase TEM-1	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	286	286	100.00	100.00	286	WP_000027057.1	broad-spectrum class A beta-lactamase TEM-1	NA	NA
```

#### What the columns are

The tabular output of AMRFinderPlus is similar to ABRicate, but includes additional information:

* Scope (Core vs. Plus): 
    * Core: Targets curated from the National Database of Antibiotic Resistant Organisms (NDARO), representing high-confidence AMR determinants.
    * Plus: Supplemental targets including virulence factors, biocide resistance, and heavy metal stress response genes.
* Method (Algorithm):
    * EXACTX / ALLELEX: Indicates a 100% match to a known protein sequence or a defined allele variant.
    * BLASTX: Indicates homology based on protein translation, facilitating the detection of divergent orthologs.
    * HMM: Identification via Hidden Markov Models; essential for resolving members of diverse protein families (e.g., efflux pumps) that share structural domains despite low sequence identity.
    * POINTX: Targeted detection of known resistance-conferring point mutations (SNPs).
* Type / Subtype: Categorizes elements into AMR, VIRULENCE, or STRESS.

### Running on the Campylobacter test file

Now running on the Campylobater

```bash
# Run the tool and specify the organism type
amrfinder -n campylobacter_isolate.fna  -O Campylobacter --plus > campylobacter_amrfinder_results.tsv

# View the results
column -t -s $'\t' campylobacter_amrfinder_results.tsv
```

The results should look like this:
```
Protein id	Contig id	Start	Stop	Strand	Element symbol	Element name	Scope	Type	Subtype	Class	Subclass	Method	Target length	Reference sequence length	% Coverage of reference	% Identity to reference	Alignment length	Closest reference accession	Closest reference name	HMM accession	HMM description
NA	ACCXAQ010000001.1	41064	41834	+	blaOXA-193	OXA-61 family class D beta-lactamase OXA-193	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	257	257	100.00	100.00	257	WP_002783228.1	OXA-61 family class D beta-lactamase OXA-193	NA	NA
NA	ACCXAQ010000009.1	1763	2707	-	arsP	organoarsenical efflux permease ArsP	plus	STRESS	METAL	ARSENIC	ORGANOARSENIC	INTERNAL_STOP	315	315	100.00	95.24	315	ACG76368.1	organoarsenical efflux permease ArsP	NA	NA
NA	ACCXAQ010000031.1	1474	2244	+	blaOXA-193	OXA-61 family class D beta-lactamase OXA-193	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	257	257	100.00	100.00	257	WP_002783228.1	OXA-61 family class D beta-lactamase OXA-193	NA	NA
```

#### Interpretation

The Campylobacter isolate is expected to carry blaOXA-193 and arsP.

The Klebsiella isolate is expected to carry several genes associated with AMR, including aac(3)-IIe, aac(6')-Ib-cr5, aph(3'')-Ib, aph(6)-Id, blaCTX-M-15, blaKPC-3, blaOXA-1, blaSHV-27, blaTEM-1, catB3, dfrA14, emrD, fosA, oqxA, oqxB, qnrB1, and sul2.


## Methodological Comparison

| Feature | ABRicate (Nucleotide Alignment) | AMRFinderPlus (Protein/HMM) |
| :--- | :--- | :--- |
| Detection Logic | BLASTN (DNA-to-DNA) | BLASTX/HMM (Protein-to-Protein) |
| Klebsiella AMR | Identified oqxAB, bla_SHV-190, fosA6 | Identified oqxAB, bla_SHV-11, fosA5, plus cirA_L58Ter |
| Campylobacter AMR | Identified bla_OXA-605 | Identified bla_OXA-193 |
| Accessory Traits | Limited to screened AMR databases | Identified heavy metal (sil, pco, ter) and virulence (rmp, iut) |

### Mechanistic Discrepancies and Biological Implications

When two different bioinformatics pipelines analyze the exact same bacterial genome and output different names for the same gene (e.g., blaOXA-605 vs. blaOXA-193 in a Campylobacter isolate), it can create confusion for epidemiological tracking. To be clear, this variation does not represent a biological change in the organism. It is an artifact of the differing methodologies, curation schemas, and alignment spaces used by the two tools.

#### There are two primary technical reasons why these methods produce different results.

1. Database Versioning and Curation Snapshots
The most common driver of nomenclature discrepancies is how databases are maintained and updated.

ABRicate's Database Structure: ABRicate utilizes local, static "snapshots" of various public databases (such as CARD, ResFinder, or NCBI) that are packaged into the software at a specific point in time. If the software image has database snapshots from an older or different curation branch, it will assign names based on the definitions available at that exact time.

AMRFinderPlus's Database Structure: AMRFinderPlus relies strictly on the NCBI Reference Gene Catalog (NDARO). This database is curated dynamically by NCBI to coordinate global submissions and standardize nomenclature across public health networks.

Because international committees constantly reclassify, rename, and merge resistance gene families as new sequences are discovered, a database snapshot taken at one time may classify a sequence as blaOXA-605, while a more recently curated or differently structured database catalog will classify the exact same sequence as blaOXA-193.

2. Alignment Logic: Nucleotide vs. Amino Acid Space
The underlying algorithm dictates how closely a query sequence must match a reference to receive a specific allelic name.

ABRicate (Nucleotide Space): ABRicate uses BLASTN (DNA-to-DNA) alignment. It evaluates the exact sequence of A, T, C, and G nucleotides. If a sequence has a silent (synonymous) mutation that changes a single nucleotide but does not alter the resulting protein, ABRicate may still classify it as a different nucleotide allele based strictly on DNA identity.

AMRFinderPlus (Protein Space): AMRFinderPlus translates the genomic DNA into an amino acid sequence (protein) and screens it using BLASTX and Hidden Markov Models (HMMs). Because the genetic code is redundant (multiple codons can code for the same amino acid), divergent nucleotide sequences can produce identical functional proteins. AMRFinderPlus will type the gene based on its functional amino acid structure (ALLELEX or EXACTX), effectively compressing multiple nucleotide variants under a single protein allele designation.

#### Why This is Volatile Across Different Organisms
As the note highlights, the specific reason for a discrepancy can change depending on the organism being studied:

In this Campylobacter case, the shift is primarily due to curation differences and database version synchronization between NCBI's reference set and the database version bundled into ABRicate.

In other organisms (like Klebsiella or Escherichia), the discrepancy might be driven by point-mutation interpretation or structural truncation detection. For instance, a nucleotide tool might flag a full-length gene based on high DNA identity, while a protein-based tool might down-type or change the name of the gene because it detects a single-nucleotide polymorphism (SNP) that changes the enzyme's binding affinity or creates a premature stop codon.

#### Summary of Implications for Public Health
For epidemiologists and laboratorians, these nomenclature differences are problematic because they can falsely suggest that two outbreaks are caused by different strains when they are actually identical. To resolve this, public health laboratories must standardize their pipelines, record the exact version numbers of the databases used, and look beyond the literal gene names to understand the functional drug resistance profile being reported.
