#!/bin/bash
if [ $# -lt 3 ] ; then
        echo ""
        echo "usage: prepare_genome_modules.sh <genome_name> <build_number> <reference.fasta> <gene_annotation.gff>"
        echo "build index for several aligners and writes a module file on condo"
        echo "does not overwrite any exisitng files"
        echo ""
        exit 0
fi

#load requried programs to create genome module files


#create local variables 
NAME="$1"
BUILD="$2"
REF="$3"
GFF="$4"
export GENMODgit="./genomeModules"
GENMOD="./"

# create a location for where to store your genome modules
GSEQ=${GENMOD}"/genomes/sequences"
GMOD=${GENMOD}"/genomes/modules"
#intervals set to 100kb
WINDOW=100000
echo $GSEQ

mkdir -p ${GSEQ}/${NAME}/${BUILD}
mkdir -p ${GMOD}/${NAME}
touch ${GMOD}/${NAME}/${BUILD}


# write a module file

cat <<MODULEFILE > ${GMOD}/${NAME}/${BUILD}
#%Module1.0#####################################################################
##
module-whatis   "${NAME}"

#unset the general variables to make sure we don't accidently load two unrelated genomes
unsetenv   GENOME
unsetenv   GMAPDB
unsetenv   GNAME

#set general variable names when working with only one genome
setenv  GENOMEDIR        ${GSEQ}/${NAME}/${BUILD}/
setenv  GENOMEFASTA	 ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.fasta
setenv	GENOMEINTERVALS	${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_coords.bed
setenv  GNAME         ${NAME}_${BUILD}
setenv  GMAPDB        ${GSEQ}/${NAME}/${BUILD}/$GNAME
setenv  modulefile	${GMOD}/${NAME}/${BUILD}
setenv	VERSION		${BUILD}
setenv  "${NAME}_${BUILD}_genome" ${GSEQ}/${NAME}/${BUILD}/
setenv  "${NAME}_${BUILD}_GMAPDB" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}
setenv  "${NAME}_${BUILD}_GNAME" ${NAME}_${BUILD}

setenv  "${NAME}_${BUILD}_intervals100k" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_coords.bed 

setenv  "${NAME}_${BUILD}_cdna" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.fasta
setenv  "${NAME}_${BUILD}_cdna" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.gff3
setenv  "${NAME}_${BUILD}_cdna" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.cdna.fasta
setenv  "${NAME}_${BUILD}_cds" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.cds.fasta
setenv  "${NAME}_${BUILD}_gene" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.gene.fasta
setenv  "${NAME}_${BUILD}_pep" ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.pep.fasta
setenv  "${NAME}_${BUILD}_upstream3000" ${NAME}_${BUILD}.upstream3000.fasta

MODULEFILE



# Create Fasta files from GFF file
if [ $# -eq 4 ] ; then
perl ${GENMODgit}/bin/gff2fasta.pl ${REF} ${GFF} ${NAME}_${BUILD}
mv ${NAME}_${BUILD}* ${GSEQ}/${NAME}/${BUILD}/
fi

# build index for GSNAP, Bowtie2, BWA and SAMTOOLS
#parallel <<FIL

${GENMODgit}/wrappers/GM gmap_build -d ${NAME}_${BUILD} -D ${GSEQ}/${NAME}/${BUILD} ${REF}
${GENMODgit}/wrappers/GM bowtie2-build ${REF} ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}
${GENMODgit}/wrappers/GM samtools faidx ${REF}
${GENMODgit}/wrappers/GM bwa index -p ${NAME}_${BUILD} -a bwtsw ${REF}
${GENMODgit}/wrappers/GM picard CreateSequenceDictionary \
  REFERENCE=${REF} \
  OUTPUT=${NAME}_${BUILD}.dict
#FIL
# cleanup
mv ${REF}.fai ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.fai
mv ${NAME}_${BUILD}* ${GSEQ}/${NAME}/${BUILD}/
mv ${NAME}_${BUILD}.dict ${GSEQ}/${NAME}/${BUILD}/
ln -s ${NAME}_${BUILD}.fai ${NAME}_${BUILD}.fasta.fai

# build intervals and cleanup
${GENMODgit}/bin/fasta_length.py ${REF} > ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_length.txt
${GENMODgit}/wrappers/GM bedtools makewindows -w ${WINDOW} -g  ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_length.txt |  awk '{print $1"\t"$2+1"\t"$3}' >  ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_coords.bed
${GENMODgit}/wrappers/GM picard BedToIntervalList \
  INPUT=${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_coords.bed \
  SEQUENCE_DICTIONARY=${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_coords.dict \
  OUTPUT=${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}_100kb_gatk_intervals.list

#move reference and GFF file to genome module locations

cp ${REF} ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.fasta
cp ${GFF} ${GSEQ}/${NAME}/${BUILD}/${NAME}_${BUILD}.gff3
