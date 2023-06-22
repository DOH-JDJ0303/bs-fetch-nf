#!/bin/bash

reads=$1
outdir=$2

echo ${reads} | tr -d '[] ' | tr ',' '\n' | sed 's/.*\///g' > r_col

cat r_col | sed -r 's/_S[0-9]+_L[0-9]+_R[12]_001.fastq.gz//g' > n_col

paste n_col r_col > all_reads

echo "sample,fastq_1,fastq_2" > manifest.csv
samples=$(cat all_reads | cut -f 1 | sort | uniq)
for s in ${samples}
do
    read_line=$(cat all_reads | awk -v s=${s} '$1 == s {print $2,$3}' | tr '\n' ',' | tr -d '\n\t\r ')
    echo "${s},${outdir%/}/reads/${read_line%,}" >> manifest.csv
done

cat manifest.csv
