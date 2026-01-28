#!/bin/bash

version="1.0"

if [[ $1 == "--version" ]]
then
    echo ${version}
else
    reads=$1
    outdir="${2%/}"

    echo ${reads} | tr -d '[] ' | tr ',' '\n' | sed 's/.*\///g' | sort | uniq > r_col

    cat r_col | sed -r 's/_S[0-9]+_L[0-9]+_R[12]_001.fastq.gz//g' > n_col

    paste n_col r_col > all_reads

    echo "sample,fastq_1,fastq_2" > manifest.csv
    samples=$(cat all_reads | cut -f 1 | sort | uniq)
    for s in ${samples}
    do

        reads_line=$(cat all_reads | awk -v s="${s}" -v o="${outdir%/}" '$1 == s {print o"/reads/"$2}' | sort | tr '\n' ',' | tr -d '\n\t\r ')
        echo "${s},${reads_line%,}" >> manifest.csv

    done

    cat manifest.csv
fi

