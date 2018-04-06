# genomeModules
build index for several aligners and writes a module file

After cloning this repository

#### Download the following singularity images and place them in SIMG folder
* singularity pull shub://ISUGIFsingularity/genomeModules:1.0.2
* singularity pull shub://ISUGIFsingularity/utilities:1.0.1 

#### Modify the following environmental variables in prepare_genome_modules.sh

Use full paths so that the module file will work correctly

```
export GENMODgit="/pylon5/mc48o5p/severin/isugif/genomeModules"
GENMOD="/pylon5/mc48o5p/severin/isugif/"
```

GENMODgit is the location of this github repository.
GENMOD is the location where you would like to store genome modules and sequence files that this script generates.

#### Running the prepare genome modules command to generate a genome module file.
I ran this on the Seriola dorsalis genome and its corresponding GFF3 file.

```
prepare_genome_modules.sh serdor v2 Serdor_V2.fasta Serdor_V2.gff3
```

#### Adding the modules to your module path.

module use $GENMOD/genomes/modules/

#### Example of a genome module



```
module load serdor
module show serdor

```
-------------------------------------------------------------------
/pylon5/mc48o5p/severin/genmodTest/genomes/modules//serdor/v2:

module-whatis    serdor 
unsetenv         GENOME 
unsetenv         GMAPDB 
unsetenv         GNAME 
setenv           GENOMEDIR .//genomes/sequences/serdor/v2/ 
setenv           GENOMEFASTA .//genomes/sequences/serdor/v2/serdor_v2.fasta 
setenv           GENOMEINTERVALS .//genomes/sequences/serdor/v2/serdor_v2_100kb_coords.bed 
setenv           GNAME serdor_v2 
setenv           GMAPDB .//genomes/sequences/serdor/v2/ 
setenv           modulefile .//genomes/modules/serdor/v2 
setenv           VERSION v2 
setenv           serdor_v2_genome .//genomes/sequences/serdor/v2/ 
setenv           serdor_v2_GMAPDB .//genomes/sequences/serdor/v2/serdor_v2 
setenv           serdor_v2_GNAME serdor_v2 
setenv           serdor_v2_intervals100k .//genomes/sequences/serdor/v2/serdor_v2_100kb_coords.bed 
setenv           serdor_v2_cdna .//genomes/sequences/serdor/v2/serdor_v2.fasta 
setenv           serdor_v2_cdna .//genomes/sequences/serdor/v2/serdor_v2.gff3 
setenv           serdor_v2_cdna .//genomes/sequences/serdor/v2/serdor_v2.cdna.fasta 
setenv           serdor_v2_cds .//genomes/sequences/serdor/v2/serdor_v2.cds.fasta 
setenv           serdor_v2_gene .//genomes/sequences/serdor/v2/serdor_v2.gene.fasta 
setenv           serdor_v2_pep .//genomes/sequences/serdor/v2/serdor_v2.pep.fasta 
setenv           serdor_v2_upstream3000 serdor_v2.upstream3000.fasta 
-------------------------------------------------------------------
```


