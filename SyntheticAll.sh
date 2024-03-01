#!/usr/bin/bash
help() {
		echo ""
		echo -e "Usage: \n\t bash $0 [options] --syn <1 or 2>"
		echo -e "  --syn \n\t\t Using synthetic spike-ins reference 1 or 2."
        echo "Options:"
		echo -e "  -t, --thread \n\t\t Numbers of threads, default: 1"
		echo -e "  -h, --help \n\t\t show help message."
		echo ""
}

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below.
TEMP=`getopt -o t:h --long help,syn: \
             -n 'SyntheticAll.sh' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

THREADS=1
SYNTHETIC=

while true; do
  case "$1" in
				--syn ) SYNTHETIC="$2"; shift 2;;
				-t | --threads ) THREADS="$2"; shift 2;;
				-h | --help)
                        help
                        exit 0;;
                -- ) shift; break ;;
                * ) echo "Invalid option: ${optionName}" ;
				   echo "Try 'bash `basename $0` -h' for more information" ; 
				   break ;;
        esac
done

PROJECTDIR=$(dirname $(pwd)) # assume in <project_dir>/src
CLEANLOC=${PROJECTDIR}/data/clean
ALIGNLOC=${PROJECTDIR}/results/align
if [[ "$SYNTHETIC" == "1" ]]; then
    REF=/public/Reference/Synthetic/index/star_index/Synthetic/
    GTF=/public/Reference/Synthetic/annotation/synthetic_v1.gtf
elif [[ "$SYNTHETIC" == "2" ]]; then
    REF=/public/Reference/Synthetic/index/star_index/SyntheticV2/
    GTF=/public/Reference/Synthetic/annotation/synthetic_v2.gtf
else
   echo "Synthetic RNA can only map to V1 (1) or V2 (2) reference."
   exit 1
fi

for id in ${ALIGNLOC}/*_align; do #change id
    PREFIX=`basename ${id%_align}` #change prefix
    echo "Processing..${id}"
    STAR --genomeDir ${REF} \
         --readFilesCommand zcat \
         --readFilesIn ${CLEANLOC}/${PREFIX}_val_1.fq.gz ${CLEANLOC}/${PREFIX}_val_2.fq.gz \
         --runThreadN ${THREADS} \
         --outFileNamePrefix ${ALIGNLOC}/${PREFIX}_align/Synthetic_
done

# PE sequencing
featureCounts -p -B -C -t gene -T ${THREADS} -a ${GTF} -o ${PROJECTDIR}/results/featurecounts/synthetic.tsv ${ALIGNLOC}/*_align/Synthetic_Aligned.out.sam 
