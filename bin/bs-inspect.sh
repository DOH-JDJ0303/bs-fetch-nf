#!/bin/bash

# input
samples=$1
access_token=$2
api=$3

# create header for output
echo "BiosampleName,FileNumber,TotalFiles,FileId,Category,ContentType,DateCreated,DateModified,ETag,Href,HrefContent,IsArchived,Name,Path,Size,UploadStatus" > bs_inspect.csv

# iterate over the sample list
for biosample in $(cat ${samples})
do
    # print biosample name
    echo -e "\n${biosample}:"
    # get list of files for biosample name
    bs biosample content -n ${biosample} --access-token ${access_token} --api-server ${api} | grep -v "Id" | cut -f 2 -d ' ' | grep -v "+" > files.txt || true

    n_files=$(cat files.txt | wc -l)
    if [[ ${n_files} > 0 ]]
    then
    counter=1
        for f in $(cat files.txt)
        do
            # print file name
            echo -e "  ${f}"
            bs file get -i ${f} --access-token ${access_token} --api-server ${api} > file.txt
            line=$(cat file.txt | tr -d '\t ' | grep -v '^+' | cut -f 3 -d '|' | tr '\n' ',')
            echo "${biosample},${counter},${n_files},${line}" >> bs_inspect.csv
            counter=$((counter+1))
        done
    else
        echo "${biosample},0,0,,,,,,,,,,,,,," >> bs_inspect.csv
    fi

done

rm file.txt files.txt 2> /dev/null || true