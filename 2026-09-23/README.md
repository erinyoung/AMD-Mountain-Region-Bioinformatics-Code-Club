# Package and Environment Management with Conda

## Session Overview

Conda is a package and environment management system. It can install software and its dependencies, while also creating isolated environments so that different projects can use different software versions.

We won't install "Conda" directly. Instead, we'll install Miniforge, a lightweight distribution that provides Conda and Mamba.

By the end of this 30-minute code-along, participants will be able to:
* Install Miniforge / Miniconda in a Linux CLI or GitHub Codespaces environment.
* Configure Channels to prioritize `conda-forge` and `bioconda` for public health bioinformatics tools.
* Create and Manage Isolated Environments to avoid dependency conflicts across pipelines.

---

## Summary

The environment isn't the software. The environment is the isolated place where the software and its dependencies live. Conda is an "easy-to-use" environment manager.

---

## Background

In public health bioinformatics, different tools often require conflicting versions of underlying dependencies (e.g., Python 2.7 vs. Python 3.10, or specific C library versions). Installing tools into a system's global environment leads to broken software pipelines. 

To solve this, package managers draw pre-compiled binaries from remote online repositories ("channels") to build isolated environments.

### Tool & Concept Overview

| Tool / Project | Category | What it is |
|---|---|---|
| **Conda** | Package & environment manager | Manages software packages, dependencies, and isolated environments. |
| **Miniconda** | Conda distribution | A minimal installer that provides Conda without a large collection of preinstalled packages. |
| **Miniforge** | Conda distribution | A lightweight Conda distribution configured for the `conda-forge` ecosystem; includes both Conda and Mamba. |
| **Anaconda** | Conda distribution | A larger Conda distribution that includes many commonly used packages and provides access to the Anaconda package repository. |
| **Mamba** | Package & environment manager | A fast implementation of Conda's package-management commands, designed to solve and install packages efficiently. |
| **Micromamba** | Package & environment manager | A small, standalone implementation of Conda's package and environment management functionality. |
| **Pixi** | Package & environment manager | A modern package and environment manager built by Prefix.dev. It uses the `conda` package ecosystem and supports reproducible project environments. |
| **conda-forge** | Package channel | A community-maintained repository of Conda packages. |
| **Bioconda** | Package channel | A Conda channel providing bioinformatics software and other computational biology packages. |

---

## 1. Tool Installation: Miniforge

While standard Miniconda defaults to commercial channels, **Miniforge** provides an identical, lightweight footprint ideal for standard GitHub Codespaces machine configurations (2-core, 4GB RAM), pre-configured with `conda-forge` and `mamba`.

```bash
# Create a workspace directory for installers
mkdir -p $HOME/installer
cd $HOME/installer

# Download the Miniforge Linux 64-bit installer
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

# Run the silent batch installer (-b) into $HOME/miniforge3 (-p)
bash Miniforge3-Linux-x86_64.sh -b -p $HOME/miniforge3

# Initialize Conda and Mamba for your bash shell
$HOME/miniforge3/bin/conda init bash

# Source bashrc to apply changes to the current terminal session
source ~/.bashrc

# Verification of successful setup
conda --version
mamba --version
```

## 2. Installing a package: seqkit

The tool [seqkit](https://bioinf.shenwei.me/seqkit/) is commonly used to assess FASTQ files and is included on bioconda. We are going to install this with conda.

### 2.1 Creating a new environment

First, we will create a conda environment. We are going to name this environment "seqkit", although it could be whatever we felt like naming it.

```bash
conda create -n seqkit
```

We will select "y" or "yes" to allow conda to create a new directory where files will get dowloaded to.

### 2.2 Activating the new environment

Now we need to "activate" the environment, otherwise we are just in base.

```bash
conda activate seqkit
```

### 2.3 Actually install seqkit

This is the command that is generally found in installation documents.

```bash
conda install seqkit
```

### 2.4 Installation error

This however, does not work. We're deliberately starting with only conda-forge so you can see what happens when the package isn't in your configured channels.

```output
Retrieving notices: done
Channels:
 - conda-forge
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: failed
Channels:
 - conda-forge
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: failed

PackagesNotFoundInChannelsError: The following packages are not available from current channels:

  - seqkit

Current channels:

  - https://conda.anaconda.org/conda-forge

To search for alternate channels that may provide the conda package you're
looking for, navigate to

    https://anaconda.org

and use the search bar at the top of the page.

```

Conda isn't saying that seqkit doesn't exist. It's saying that seqkit isn't available in the channels we've currently configured.

### 2.5 Add a channel

We need to add a channel option in order to get this installed.


```bash
conda install -c bioconda seqkit
```

This will list all the required packages associated with this and ask us for permission to install. Select "y".

### 2.6 Ensure it works.

Try the `-h` flag to make sure that is in PATH.

```bash
seqkit -h
```

It can actually run on files in this repo.

```bash
seqkit stats /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/*.fastq.gz 
```

```output
processed files:  4 / 4 [======================================] ETA: 0s. done
file                                                                                   format  type  num_seqs  sum_len  min_len  avg_len  max_len
/workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/mev-pat-toy_R1.fastq.gz  FASTQ   DNA        394   49,832       27    126.5      150
/workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/mev-pat-toy_R2.fastq.gz  FASTQ   DNA        395   50,225       26    127.2      150
/workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/mev-ww-toy_R1.fastq.gz   FASTQ   DNA        398   49,364       40      124      151
/workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/mev-ww-toy_R2.fastq.gz   FASTQ   DNA        394   48,780       40    123.8      151
```

### 2.7 Deactivate environment

When we're done with the conda environment, we can leave it with `conda deactivate`.

```bash
conda deactivate
```

### 2.8 Fail at running seqkit

Now if we try to run seqkit, we won't be able to.

```bash
seqkit -h
```

The error will be the following.

```output
bash: seqkit: command not found
```

Reminder: this is a feature of conda. It allows discrete conda environments so that tool dependencies don't run into issues.

## 3. Configuring Channels for Bioinformatics

Conda searches online "channels" to download pre-compiled binaries. For public health workflows, conda-forge and bioconda are essential repositories.

### 3.1 Adding some channels

```bash
conda config --add channels bioconda
conda config --add channels conda-forge
```

Once Bioconda is configured, Conda will search it automatically, so we can install Bioconda packages without specifying `-c bioconda` each time.

### 3.2 Checking configured channels

It is possible to see what channels are already configured.

```
conda config --show channels
```

## 4. Environment files

Sometimes environments are complicated or need better notation. In those instances, installing from a file would be best practice.

An environment file looks something like this:

```yml
name: seqtk
channels:
  - conda-forge
  - bioconda
dependencies:
  - seqtk
```

This specifies the name of the conda environment (`seqtk`), what channels are going to be used (`conda-forge` and `bioconda`), and then the conda packages (`seqtk`).

This file is found in `2026-09-23/environment.yml`

The YAML file describes the environment we want. Conda reads this specification and solves the dependencies needed to create the environment.

### 4.1 Installing seqtk with an environment.yml file

A file can be given to conda with `-f`.

```bash
conda create -f /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/2026-09-23/environment.yml
```

Select "y" to install. This looks very similar to the other method.

### 4.2 Activate the new environment

This new environment can be used like the prior example.

```bash
conda activate seqtk
```


### 4.3 Test seqtk

The help message should work
```bash
seqtk
```

And it will hopefully run smoothly.

```bash
seqtk fqchk /workspaces/AMD-Mountain-Region-Bioinformatics-Code-Club/data/*fastq.gz
```

And it looks like is working as expected.
```output
min_len: 27; max_len: 150; avg_len: 126.48; 4 distinct quality values
POS     #bases  %A      %C      %G      %T      %N      avgQ    errQ    %low    %high
ALL     49832   26.6    23.4    23.5    26.5    0.0     32.9    25.8    3.3     96.7
1       394     22.8    23.6    38.6    15.0    0.0     33.5    32.7    0.0     100.0
2       394     22.6    25.1    20.8    31.5    0.0     32.7    25.4    3.8     96.2
3       394     23.9    26.6    17.8    31.7    0.0     32.9    26.2    3.0     97.0
4       394     21.1    32.2    15.7    31.0    0.0     32.7    25.4    3.8     96.2
5       394     30.7    18.3    16.5    34.5    0.0     32.9    26.2    3.0     97.0
6       394     38.6    17.3    29.7    14.5    0.0     32.5    24.5    4.8     95.2
7       394     31.7    19.0    29.9    19.3    0.0     33.2    27.2    2.3     97.7
8       394     27.2    17.0    25.9    29.9    0.0     32.8    25.6    3.6     96.4
9       394     16.0    34.5    28.7    20.8    0.0     33.0    27.1    2.3     97.7
10      394     29.9    22.1    16.8    31.2    0.0     33.1    27.5    2.0     98.0
11      394     21.1    19.5    34.0    25.4    0.0     33.2    26.9    2.5     97.5
12      394     27.2    21.3    21.3    30.2    0.0     32.8    26.1    3.0     97.0
13      394     22.8    29.4    23.9    23.9    0.0     32.9    25.2    4.1     95.9
14      394     21.3    33.2    18.0    27.4    0.0     33.0    26.5    2.8     97.2
15      394     33.0    23.4    21.6    22.1    0.0     33.0    26.2    3.0     97.0
16      394     25.4    20.8    27.7    26.1    0.0     33.0    26.2    3.0     97.0
17      394     23.4    24.4    25.6    26.6    0.0     32.9    25.9    3.3     96.7
18      394     30.7    19.3    25.6    24.4    0.0     32.8    25.4    3.8     96.2
19      394     25.6    19.3    22.8    32.2    0.0     32.8    25.0    4.3     95.7
20      394     22.8    21.6    22.6    33.0    0.0     33.0    26.0    3.3     96.7
21      394     26.6    23.6    19.8    29.9    0.0     33.2    26.6    2.8     97.2
22      394     25.4    23.6    24.9    26.1    0.0     33.3    28.4    1.5     98.5
23      394     33.0    20.8    23.4    22.8    0.0     33.1    26.0    3.3     96.7
24      394     24.9    21.8    24.1    29.2    0.0     32.7    25.0    4.3     95.7
25      394     29.2    23.6    22.6    24.6    0.0     32.9    25.7    3.6     96.4
26      394     27.7    22.1    20.3    29.9    0.0     32.9    26.2    3.0     97.0
27      394     26.9    22.8    24.4    25.9    0.0     32.9    25.9    3.3     96.7
28      393     27.0    23.7    22.6    26.7    0.0     33.0    25.9    3.3     96.7
29      393     28.2    22.6    24.4    24.7    0.0     32.9    26.7    2.5     97.5
30      392     23.7    25.0    26.5    24.7    0.0     33.2    27.2    2.3     97.7
31      392     27.3    21.4    20.9    30.4    0.0     32.6    24.9    4.3     95.7
32      392     27.0    18.9    25.3    28.8    0.0     32.9    26.2    3.1     96.9
33      392     21.4    23.5    28.6    26.5    0.0     33.2    27.5    2.0     98.0
34      392     26.5    24.0    20.9    28.6    0.0     32.9    26.2    3.1     96.9
35      392     24.0    27.8    22.7    25.5    0.0     33.4    28.9    1.3     98.7
36      392     26.8    20.4    22.7    30.1    0.0     32.9    25.9    3.3     96.7
37      391     31.5    22.3    19.2    27.1    0.0     33.0    26.5    2.8     97.2
38      391     26.9    22.8    25.6    24.8    0.0     32.7    25.4    3.8     96.2
39      391     26.9    21.2    25.1    26.9    0.0     32.8    25.8    3.3     96.7
40      391     26.9    22.8    21.5    28.9    0.0     32.9    26.4    2.8     97.2
41      391     26.6    27.4    20.7    25.3    0.0     32.8    25.2    4.1     95.9
42      391     21.0    25.1    25.3    28.6    0.0     33.1    26.2    3.1     96.9
43      391     22.3    24.8    21.7    31.2    0.0     33.1    26.5    2.8     97.2
44      391     26.1    26.6    22.5    24.8    0.0     33.2    26.6    2.8     97.2
45      391     28.9    22.0    17.4    31.7    0.0     33.1    26.5    2.8     97.2
46      391     26.1    23.0    22.0    28.9    0.0     33.1    27.4    2.0     98.0
47      391     23.8    31.5    23.5    21.2    0.0     33.1    27.8    1.8     98.2
48      390     30.3    22.6    24.4    22.8    0.0     32.9    26.1    3.1     96.9
49      390     29.5    22.8    26.4    21.3    0.0     33.0    26.8    2.6     97.4
50      389     26.2    26.0    24.4    23.4    0.0     32.9    25.9    3.3     96.7
51      388     21.1    25.8    25.0    28.1    0.0     33.2    27.5    2.1     97.9
52      386     25.1    26.9    19.7    28.2    0.0     32.7    25.5    3.6     96.4
53      386     26.7    24.4    18.4    30.6    0.0     33.1    27.8    1.8     98.2
54      384     25.8    27.9    24.2    22.1    0.0     33.1    26.7    2.6     97.4
55      384     30.7    19.5    22.1    27.6    0.0     33.0    26.7    2.6     97.4
56      384     24.2    25.3    23.2    27.3    0.0     33.2    26.5    2.9     97.1
57      384     23.7    25.0    24.2    27.1    0.0     33.3    27.9    1.8     98.2
58      383     26.1    26.4    22.2    25.3    0.0     32.6    24.8    4.4     95.6
59      383     23.2    27.4    26.4    23.0    0.0     33.3    27.2    2.3     97.7
60      383     28.2    21.4    21.7    28.7    0.0     33.0    26.1    3.1     96.9
61      381     26.8    25.7    20.7    26.8    0.0     33.0    25.8    3.4     96.6
62      379     30.6    22.2    20.1    27.2    0.0     33.1    26.1    3.2     96.8
63      379     25.6    24.8    19.3    30.3    0.0     32.8    25.8    3.4     96.6
64      377     28.9    22.8    20.4    27.9    0.0     32.6    24.1    5.6     94.4
65      377     27.3    23.1    23.3    26.3    0.0     32.7    25.7    3.4     96.6
66      375     24.5    25.1    26.7    23.7    0.0     32.8    25.5    3.7     96.3
67      374     21.1    21.7    25.9    31.3    0.0     32.8    25.7    3.5     96.5
68      374     26.5    24.6    21.9    27.0    0.0     33.3    27.4    2.1     97.9
69      372     27.4    20.7    26.6    25.3    0.0     32.9    25.7    3.5     96.5
70      372     28.0    20.2    23.9    28.0    0.0     33.2    27.8    1.9     98.1
71      372     25.3    25.8    17.2    31.7    0.0     32.9    26.0    3.2     96.8
72      371     27.2    20.8    20.8    31.3    0.0     32.6    24.9    4.3     95.7
73      369     23.8    27.9    22.8    25.5    0.0     32.8    24.6    4.9     95.1
74      369     29.5    23.3    25.2    22.0    0.0     32.7    25.6    3.5     96.5
75      368     23.1    23.1    25.0    28.8    0.0     32.9    26.5    2.7     97.3
76      367     29.2    17.4    27.5    25.9    0.0     32.8    25.4    3.8     96.2
77      366     23.8    26.0    23.8    26.5    0.0     32.8    25.4    3.8     96.2
78      365     26.6    27.7    21.1    24.7    0.0     32.5    24.8    4.4     95.6
79      365     27.7    33.4    18.1    20.8    0.0     32.6    25.1    4.1     95.9
80      362     28.7    23.2    21.8    26.2    0.0     32.7    25.6    3.6     96.4
81      361     28.8    21.1    23.3    26.9    0.0     32.8    25.1    4.2     95.8
82      360     29.4    23.1    22.8    24.7    0.0     32.5    24.8    4.4     95.6
83      356     25.0    23.9    18.8    32.3    0.0     32.8    25.3    3.9     96.1
84      355     23.9    24.2    23.4    28.5    0.0     32.8    25.3    3.9     96.1
85      355     27.0    22.3    23.1    27.6    0.0     33.0    26.1    3.1     96.9
86      354     29.7    23.2    25.7    21.5    0.0     33.0    26.1    3.1     96.9
87      351     30.8    17.4    27.6    24.2    0.0     32.6    24.7    4.6     95.4
88      350     24.9    21.4    25.4    28.3    0.0     32.9    25.5    3.7     96.3
89      350     29.4    20.9    25.7    24.0    0.0     33.0    26.4    2.9     97.1
90      346     26.9    24.3    24.3    24.6    0.0     32.9    25.5    3.8     96.2
91      345     24.1    25.8    23.8    26.4    0.0     33.0    26.1    3.2     96.8
92      341     27.6    19.6    25.8    27.0    0.0     32.9    26.0    3.2     96.8
93      340     27.6    18.8    25.0    28.5    0.0     32.9    26.3    2.9     97.1
94      338     23.7    22.2    26.3    27.8    0.0     32.7    25.6    3.6     96.4
95      337     25.2    24.3    22.3    28.2    0.0     32.7    24.9    4.5     95.5
96      334     29.3    20.1    23.1    27.5    0.0     32.7    25.1    4.2     95.8
97      331     26.6    25.1    21.8    26.6    0.0     33.3    28.4    1.5     98.5
98      328     27.7    21.6    25.9    24.7    0.0     33.1    26.6    2.7     97.3
99      327     24.5    23.2    27.5    24.8    0.0     32.6    24.5    4.9     95.1
100     325     30.2    23.4    23.1    23.4    0.0     32.6    24.7    4.6     95.4
101     324     25.9    20.7    29.9    23.5    0.0     33.1    26.6    2.8     97.2
102     324     28.7    21.6    25.0    24.7    0.0     32.8    25.8    3.4     96.6
103     321     28.3    18.4    21.5    31.8    0.0     33.0    27.2    2.2     97.8
104     319     26.0    26.6    20.4    27.0    0.0     33.3    27.4    2.2     97.8
105     316     25.6    25.9    24.1    24.4    0.0     32.4    23.9    5.7     94.3
106     311     28.9    21.2    22.5    27.3    0.0     33.1    26.4    2.9     97.1
107     306     24.5    24.5    25.5    25.5    0.0     33.3    28.2    1.6     98.4
108     304     27.3    24.7    24.3    23.7    0.0     32.8    26.2    3.0     97.0
109     301     20.3    20.6    25.9    33.2    0.0     32.6    24.9    4.3     95.7
110     298     25.5    20.1    24.8    29.5    0.0     32.5    24.1    5.4     94.6
111     297     27.3    20.5    26.3    25.9    0.0     33.1    26.7    2.7     97.3
112     297     30.0    18.2    27.9    23.9    0.0     32.9    26.2    3.0     97.0
113     294     28.9    24.1    22.1    24.5    0.3     32.9    24.3    2.7     97.3
114     291     22.7    26.5    19.2    31.6    0.0     32.9    26.5    2.7     97.3
115     291     23.0    25.4    19.9    31.6    0.0     32.9    25.8    3.4     96.6
116     289     28.0    25.3    25.3    21.5    0.0     33.0    26.1    3.1     96.9
117     284     32.4    25.4    19.7    22.5    0.0     32.9    25.7    3.5     96.5
118     277     28.5    22.4    24.2    24.5    0.4     32.4    22.8    5.1     94.9
119     274     28.5    22.3    21.5    27.7    0.0     32.6    25.2    4.0     96.0
120     271     22.1    19.6    27.3    31.0    0.0     32.8    26.2    3.0     97.0
121     266     24.8    21.4    27.1    26.7    0.0     33.2    26.3    3.0     97.0
122     264     22.7    23.5    26.1    27.7    0.0     32.8    25.7    3.4     96.6
123     258     29.5    25.2    23.3    22.1    0.0     33.2    26.7    2.7     97.3
124     255     29.4    23.9    23.9    22.7    0.0     32.5    24.3    5.1     94.9
125     254     34.6    21.3    20.1    24.0    0.0     32.8    26.0    3.1     96.9
126     248     21.4    21.8    24.6    32.3    0.0     33.3    28.2    1.6     98.4
127     243     29.6    18.1    26.3    25.9    0.0     32.7    25.8    3.3     96.7
128     233     25.8    25.3    24.5    24.5    0.0     32.9    25.8    3.4     96.6
129     229     27.5    25.8    24.0    22.7    0.0     33.5    29.9    0.9     99.1
130     227     29.5    22.5    22.0    26.0    0.0     33.0    26.6    2.6     97.4
131     222     23.9    26.6    26.1    23.4    0.0     32.8    25.6    3.6     96.4
132     219     27.4    24.2    22.8    25.6    0.0     32.8    25.6    3.7     96.3
133     217     26.3    29.5    20.7    23.5    0.0     32.6    25.4    3.7     96.3
134     213     33.3    23.0    19.2    24.4    0.0     32.4    23.7    6.1     93.9
135     208     28.4    27.4    21.6    22.6    0.0     32.4    24.5    4.8     95.2
136     199     22.6    23.1    27.6    26.6    0.0     32.3    23.7    6.0     94.0
137     197     29.4    13.7    30.5    26.4    0.0     32.2    23.9    5.6     94.4
138     192     21.4    19.3    29.2    26.6    3.6     31.5    16.6    8.3     91.7
139     191     26.2    18.3    25.1    30.4    0.0     32.5    24.6    4.7     95.3
140     187     27.3    28.3    24.6    19.8    0.0     32.9    27.2    2.1     97.9
141     183     26.8    25.1    24.0    24.0    0.0     32.1    24.0    5.5     94.5
142     178     30.3    21.3    27.5    20.8    0.0     32.4    25.6    3.4     96.6
143     172     26.2    20.9    23.8    29.1    0.0     32.7    24.7    4.7     95.3
144     165     35.2    18.2    24.2    22.4    0.0     32.5    24.5    4.8     95.2
145     162     29.0    25.9    20.4    24.7    0.0     32.7    25.0    4.3     95.7
146     160     30.6    29.4    13.8    26.2    0.0     32.0    23.2    6.9     93.1
147     157     34.4    21.7    19.7    24.2    0.0     31.9    23.1    7.0     93.0
148     142     31.0    30.3    21.8    16.9    0.0     32.6    25.0    4.2     95.8
149     123     23.6    17.9    26.8    31.7    0.0     33.2    29.7    0.8     99.2
150     78      19.2    16.7    28.2    35.9    0.0     32.9    26.7    2.6     97.4
```

### 4.4 Deactivate the conda environment

```
conda deactivate
```

## Summary and common commands

### Managing Environments
* `conda env list` — List all environments on your system and highlight the active one with an asterisk (`*`).
* `conda create -n <env_name> python=3.10` — Create a new environment with a specific Python version.
* `conda activate <env_name>` — Activate a target environment.
* `conda deactivate` — Exit the active environment back to `base`.
* `conda env remove -n <env_name>` — Completely delete an environment and all its installed packages.
* `conda env export > environment.yml` — Export the current environment configuration to a shareable file.
* `conda env create -f environment.yml` — Build an environment from an existing YAML file.

### Managing Packages
* `conda list` — Show all packages installed in the currently active environment.
* `conda install <package_name>` — Install a package into the current environment.
* `conda install -c <channel> <package_name>` — Install a package from a specific channel (e.g., `-c bioconda`).
* `conda remove <package_name>` — Uninstall a package from the active environment.
* `conda search <package_name>` — Search configured channels for available versions of a package.
* `conda update --all` — Update all packages in the current environment to their latest compatible versions.

### System Inspection & Cleanup
* `conda info` — Display system details, active environment paths, and channel configurations.
* `conda config --show channels` — View the current priority list of configured package channels.
* `conda clean --all` — Delete cached package tarballs and temporary index files to free up disk space.