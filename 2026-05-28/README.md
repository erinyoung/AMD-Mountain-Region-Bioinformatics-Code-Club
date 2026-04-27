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
* _Klebsiella pneumoniae_: [GCF_002813595.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_002813595.1/)
* _Campylobacter jejuni_: [GCA_056635755.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_056635755.1/)

### Downloading the Klebsiella test file

```bash
# Download the zipped assembly file from NCBI
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/813/ 595/GCF_002813595.1_ASM281359v1/GCF_002813595.1_ASM281359v1_genomic.fna.gz

# Decompress the file so our tools can read it
gunzip GCF_002813595.1_ASM281359v1_genomic.fna.gz

# Rename the file to something simple
mv GCF_002813595.1_ASM281359v1_genomic.fna klebsiella_isolate.fna
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
klebsiella_isolate.fna	NZ_CP025080.1	1174411	1177563	-	oqxB12	1-3153/3153	===============	0/0	100.00	99.46	ncbi	NG_050430.1	multidrug efflux RND transporter permease subunit OqxB12	PHENICOL;QUINOLONE
klebsiella_isolate.fna	NZ_CP025080.1	1177587	1178762	-	oqxA5	1-1176/1176	===============	0/0	100.00	99.66	ncbi	NG_050423.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA5	PHENICOL;QUINOLONE
klebsiella_isolate.fna	NZ_CP025080.1	2859578	2860438	+	blaSHV-190	1-861/861	===============	0/0	100.00	99.88	ncbi	NG_050056.1	class A beta-lactamase SHV-190	BETA-LACTAM
klebsiella_isolate.fna	NZ_CP025080.1	4733494	4733913	-	fosA6	1-420/420	===============	0/0	100.00	98.33	ncbi	NG_051497.1	fosfomycin resistance glutathione transferase FosA6	FOSFOMYCIN
```

#### What the columns are

The tabular output enables a granular assessment of the genomic context and confidence intervals for each identified locus:

* SEQUENCE / START / END: Specify the topological coordinates of the hit within the assembly. 
* GENE / PRODUCT: Define the specific allelic variant and its associated biochemical function.
* %COVERAGE / COVERAGE_MAP: Represent the proportion of the reference gene identified in the query sequence. A 100% value signifies a full-length coding sequence. Lower values may indicate truncated alleles or assembly discontinuities at gene boundaries.
* %IDENTITY: The percentage of identical nucleotides across the alignment. High identity (>98%) suggests a high-confidence ortholog, while lower values may indicate novel allelic variants or sequencing artifacts.
* RESISTANCE: The predicted phenotypic resistance profile associated with the identified genotype.

#### Interpretation

Campylobacter jejuni harbors bla_OXA-605, an OXA-61 family Class D beta-lactamase. The detection of this locus on two distinct sequences (ACCXAQ010000001.1 and ACCXAQ010000031.1) suggests either gene duplication or the presence of multiple copies across the accessory genome.

The profile of the Klebsiella pneumoniae indicates a multidrug-resistant (MDR) genotype: oqxA5 / oqxB12, bla_SHV-190, and fosA6.

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
NA	NZ_CP025080.1	29523	30704	-	emrD	multidrug efflux MFS transporter EmrD	plus	AMR	AMR	EFFLUX	EFFLUX	BLASTX	394	394	100.00	99.49	394	ACN65732.1	multidrug efflux MFS transporter EmrD	NA	NA
NA	NZ_CP025080.1	1174414	1177563	-	oqxB19	multidrug efflux RND transporter permease subunit OqxB19	core	AMR	AMR	PHENICOL/QUINOLONE	PHENICOL/QUINOLONE	ALLELEX	1050	1050	100.00	100.00	1050	WP_004149399.1	multidrug efflux RND transporter permease subunit OqxB19	NA	NA
NA	NZ_CP025080.1	1177590	1178762	-	oqxA	multidrug efflux RND transporter periplasmic adaptor subunit OqxA	core	AMR	AMR	NITROFURAN/PHENICOL/QUINOLONE/TETRACYCLINE	NITROFURANTOIN/PHENICOL/QUINOLONE/TIGECYCLINE	EXACTX	391	391	100.00	100.00	391	WP_002914189.1	multidrug efflux RND transporter periplasmic adaptor subunit OqxA	NA	NA
NA	NZ_CP025080.1	1603564	1605534	+	cirA_L58Ter	Klebsiella pneumoniae cefiderocol resistant CirA	core	AMR	POINT_DISRUPT	BETA-LACTAM	CEFIDEROCOL	POINTX	657	657	100.00	99.70	657	WP_002912926.1	catecholate siderophore receptor CirA	NA	NA
NA	NZ_CP025080.1	1786275	1795892	+	clbB	colibactin hybrid non-ribosomal peptide synthetase/type I polyketide synthase ClbB	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	3206	3206	100.00	99.97	3206	AMQ58400.1	colibactin hybrid non-ribosomal peptide synthetase/type I polyketide synthase ClbB	NA	NA
NA	NZ_CP025080.1	1825991	1830355	+	clbN	colibactin non-ribosomal peptide synthetase ClbN	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	1455	1455	100.00	100.00	1455	AMH08480.1	colibactin non-ribosomal peptide synthetase ClbN	NA	NA
NA	NZ_CP025080.1	1878623	1880422	+	ybtP	yersiniabactin ABC transporter ATP-binding/permease protein YbtP	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	600	600	100.00	98.83	600	CAA21388.1	yersiniabactin ABC transporter ATP-binding/permease protein YbtP	NA	NA
NA	NZ_CP025080.1	1880412	1882211	+	ybtQ	yersiniabactin ABC transporter ATP-binding/permease protein YbtQ	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	600	600	100.00	99.00	600	AAC69584.1	yersiniabactin ABC transporter ATP-binding/permease protein YbtQ	NA	NA
NA	NZ_CP025080.1	1933749	1935842	+	mchF	microcin H47 export transporter peptidase/ATP-binding subunit MchF	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	698	698	100.00	100.00	698	AAL08400.1	microcin H47 export transporter peptidase/ATP-binding subunit MchF	NA	NA
NA	NZ_CP025080.1	2859578	2860435	+	blaSHV-11	broad-spectrum class A beta-lactamase SHV-11	core	AMR	AMR	BETA-LACTAM	BETA-LACTAM	ALLELEX	286	286	100.00	100.00	286	WP_004176269.1	broad-spectrum class A beta-lactamase SHV-11	NA	NA
NA	NZ_CP025080.1	4733497	4733913	-	fosA	FosA5 family fosfomycin resistance glutathione transferase	core	AMR	AMR	FOSFOMYCIN	FOSFOMYCIN	EXACTX	139	139	100.00	100.00	139	WP_004146118.1	FosA5 family fosfomycin resistance glutathione transferase	NA	NA
NA	NZ_CP025080.1	5370063	5370962	-	fieF	CDF family cation-efflux transporter FieF	plus	STRESS	METAL	NA	NA	EXACTX	300	300	100.00	100.00	300	BAB89353.1	CDF family cation-efflux transporter FieF	NA	NA
NA	NZ_CP025081.1	23982	25454	-	silS	copper/silver sensor histidine kinase SilS	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	491	491	100.00	98.98	491	SPD96882.1	copper/silver sensor histidine kinase SilS	NA	NA
NA	NZ_CP025081.1	25450	26127	-	silR	copper/silver response regulator transcription factor SilR	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	226	226	100.00	97.35	226	SPD96883.1	copper/silver response regulator transcription factor SilR	NA	NA
NA	NZ_CP025081.1	26317	27699	+	silC	Cu(+)/Ag(+) efflux RND transporter outer membrane channel SilC	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	461	461	100.00	99.35	461	SPD96884.1	Cu(+)/Ag(+) efflux RND transporter outer membrane channel SilC	NA	NA
NA	NZ_CP025081.1	27731	28090	+	silF	Cu(+)/Ag(+) efflux RND transporter periplasmic metallochaperone SilF	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	120	117	100.00	94.17	120	KGL71342.1	Cu(+)/Ag(+) efflux RND transporter periplasmic metallochaperone SilF	NA	NA
NA	NZ_CP025081.1	28207	29496	+	silB	Cu(+)/Ag(+) efflux RND transporter periplasmic adaptor subunit SilB	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	430	430	100.00	98.14	430	AAD11748.1	Cu(+)/Ag(+) efflux RND transporter periplasmic adaptor subunit SilB	NA	NA
NA	NZ_CP025081.1	29510	32653	+	silA	Cu(+)/Ag(+) efflux RND transporter permease subunit SilA	plus	STRESS	METAL	COPPER/SILVER	COPPER/SILVER	BLASTX	1048	1048	100.00	98.85	1048	AAD11749.1	Cu(+)/Ag(+) efflux RND transporter permease subunit SilA	NA	NA
NA	NZ_CP025081.1	33289	35754	+	silP	Ag(+)-translocating P-type ATPase SilP	plus	STRESS	METAL	SILVER	SILVER	BLASTX	822	824	99.64	94.53	823	AAD11750.1	Ag(+)-translocating P-type ATPase SilP	NA	NA
NA	NZ_CP025081.1	37738	39552	+	pcoA	multicopper oxidase PcoA	plus	STRESS	METAL	COPPER	COPPER	BLASTX	605	605	100.00	99.83	605	CAA58525.1	multicopper oxidase PcoA	NA	NA
NA	NZ_CP025081.1	39561	40448	+	pcoB	copper-binding protein PcoB	plus	STRESS	METAL	COPPER	COPPER	BLASTX	296	296	100.00	99.66	296	CAA58526.1	copper-binding protein PcoB	NA	NA
NA	NZ_CP025081.1	40491	40868	+	pcoC	copper resistance system metallochaperone PcoC	plus	STRESS	METAL	COPPER	COPPER	EXACTX	126	126	100.00	100.00	126	CAA58527.1	copper resistance system metallochaperone PcoC	NA	NA
NA	NZ_CP025081.1	40876	41802	+	pcoD	copper resistance inner membrane protein PcoD	plus	STRESS	METAL	COPPER	COPPER	BLASTX	309	309	100.00	99.35	309	CAA58528.1	copper resistance inner membrane protein PcoD	NA	NA
NA	NZ_CP025081.1	41860	42537	+	pcoR	copper response regulator transcription factor PcoR	plus	STRESS	METAL	COPPER	COPPER	EXACTX	226	226	100.00	100.00	226	CAA58529.1	copper response regulator transcription factor PcoR	NA	NA
NA	NZ_CP025081.1	42537	43934	+	pcoS	copper resistance membrane spanning protein PcoS	plus	STRESS	METAL	COPPER	COPPER	BLASTX	466	466	100.00	99.14	466	CAA58530.1	copper resistance membrane spanning protein PcoS	NA	NA
NA	NZ_CP025081.1	112378	113490	+	iroB	salmochelin biosynthesis C-glycosyltransferase IroB	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	371	371	100.00	90.30	371	EOW04219.1	salmochelin biosynthesis C-glycosyltransferase IroB	NA	NA
NA	NZ_CP025081.1	113636	117271	+	iroC	salmochelin/enterobactin export ABC transporter IroC	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	1212	1219	99.51	89.04	1213	AUH19662.1	salmochelin/enterobactin export ABC transporter IroC	NA	NA
NA	NZ_CP025081.1	117385	118611	+	iroD	catecholate siderophore esterase IroD	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	409	409	100.00	98.78	409	AVE24993.1	catecholate siderophore esterase IroD	NA	NA
NA	NZ_CP025081.1	119074	121245	+	iroN	siderophore salmochelin receptor IroN	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	724	724	100.00	100.00	724	BAH65949.1	siderophore salmochelin receptor IroN	NA	NA
NA	NZ_CP025081.1	121677	122576	-	peg-344	DMT family inner membrane transporter PEG344	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	300	300	100.00	100.00	300	BAH65947.1	DMT family inner membrane transporter PEG344	NA	NA
NA	NZ_CP025081.1	122652	123050	-	rmpC	mucoid phenotype regulator RmpC	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	133	133	100.00	90.23	133	AIK83625.1	mucoid phenotype regulator RmpC	NA	NA
NA	NZ_CP025081.1	123406	123525	-	rmpD	mucoid phenotype synthesis protein RmpD	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	40	40	100.00	100.00	40	QIK04195.1	mucoid phenotype synthesis protein RmpD	NA	NA
NA	NZ_CP025081.1	123584	124213	-	rmpA	mucoid phenotype regulator RmpA	plus	VIRULENCE	VIRULENCE	NA	NA	EXACTX	210	210	100.00	100.00	210	AMA27886.1	mucoid phenotype regulator RmpA	NA	NA
NA	NZ_CP025081.1	141346	143064	+	iucA	aerobactin synthase IucA	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	573	576	99.83	90.09	575	EGI25746.1	aerobactin synthase IucA	NA	NA
NA	NZ_CP025081.1	143071	144015	+	iucB	N(6)-hydroxylysine O-acetyltransferase IucB	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	315	315	100.00	94.60	315	AAN82074.1	N(6)-hydroxylysine O-acetyltransferase IucB	NA	NA
NA	NZ_CP025081.1	144018	145748	+	iucC	NIS family aerobactin synthetase IucC	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	577	580	99.48	92.72	577	AAN82073.1	NIS family aerobactin synthetase IucC	NA	NA
NA	NZ_CP025081.1	147126	149312	+	iutA	ferric aerobactin receptor IutA	plus	VIRULENCE	VIRULENCE	NA	NA	BLASTX	729	731	99.73	89.57	729	AAN45165.2	ferric aerobactin receptor IutA	NA	NA
NA	NZ_CP025081.1	177316	177888	-	terE	tellurium resistance cAMP binding protein TerE	plus	STRESS	METAL	TELLURIUM	TELLURIUM	BLASTX	191	191	100.00	98.95	191	AAA98293.1	tellurium resistance cAMP binding protein TerE	NA	NA
NA	NZ_CP025081.1	177978	178553	-	terD	tellurium resistance membrane protein TerD	plus	STRESS	METAL	TELLURIUM	TELLURIUM	BLASTX	192	192	100.00	98.96	192	AAA98292.1	tellurium resistance membrane protein TerD	NA	NA
NA	NZ_CP025081.1	178595	179632	-	terC	tellurium resistance membrane protein TerC	plus	STRESS	METAL	TELLURIUM	TELLURIUM	BLASTX	346	346	100.00	99.13	346	AAA98291.1	tellurium resistance membrane protein TerC	NA	NA
NA	NZ_CP025081.1	179659	180111	-	terB	tellurium resistance membrane protein TerB	plus	STRESS	METAL	TELLURIUM	TELLURIUM	EXACTX	151	151	100.00	100.00	151	ACI12150.1	tellurium resistance membrane protein TerB	NA	NA
NA	NZ_CP025081.1	180137	181285	-	terA	tellurium resistance system protein TerA	plus	STRESS	METAL	NA	NA	BLASTX	383	383	100.00	97.39	383	AHE47495.1	tellurium resistance system protein TerA	NA	NA
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


## Methodological Comparison

| Feature | ABRicate (Nucleotide Alignment) | AMRFinderPlus (Protein/HMM) |
| :--- | :--- | :--- |
| Detection Logic | BLASTN (DNA-to-DNA) | BLASTX/HMM (Protein-to-Protein) |
| Klebsiella AMR | Identified oqxAB, bla_SHV-190, fosA6 | Identified oqxAB, bla_SHV-11, fosA5, plus cirA_L58Ter |
| Campylobacter AMR | Identified bla_OXA-605 | Identified bla_OXA-193 |
| Accessory Traits | Limited to screened AMR databases | Identified heavy metal (sil, pco, ter) and virulence (rmp, iut) |

### Mechanistic Discrepancies and Biological Implications

The discrepancy between the two tools is most evident in the detection of non-functional or truncated determinants. In the Klebsiella isolate, ABRicate identifies the presence of the cirA locus; however, AMRFinderPlus identifies a POINT_DISRUPT event (cirA_L58Ter). This premature stop codon renders the catecholate siderophore receptor non-functional. ABRicate, relying solely on nucleotide identity, lacks the translational logic required to flag this as a resistance marker.

In the Campylobacter isolate, the variation in allelic nomenclature, bla_OXA-605 versus bla_OXA-193, is a result of differing versioning and curation between the NCBI and ABRicate’s database snapshots. Notably, AMRFinderPlus identified an internal stop codon in the arsP permease (95.24% identity), demonstrating sensitivity to pseudogene formation that simple DNA alignment often overlooks. For the bioinformatician, these results emphasize that while ABRicate provides a rapid "first-pass" screen, AMRFinderPlus is required to resolve the translational reality of the bacterial resistome.
