process BS_INSPECT_BIOSAMPLE {
    input:
    tuple val(biosample)

    output:
    path "*.csv"       , emit: result
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    # print biosample name
    echo -e "\n!{biosample}:"

    # get list of files for biosample name
    bs biosample content -n !{biosample} --access-token !{params.access_token} --api-server !{params.api_server} | grep -v "Id" | cut -f 2 -d ' ' | grep -v "+" > files.txt || true

    n_files=$(cat files.txt | wc -l)
    if [[ ${n_files} > 0 ]]
    then
    counter=1
        for f in $(cat files.txt)
        do
            # print file name
            echo -e "  ${f}"
            bs file get -i ${f} --access-token !{params.access_token} --api-server !{params.api_server} > file.txt
            line=$(cat file.txt | tr -d '\t ' | grep -v '^+' | cut -f 3 -d '|' | tr '\n' ',')
            echo "${biosample},${counter},${n_files},${line}" >> !{biosample}.csv
            counter=$((counter+1))
        done
    else
        echo "${biosample},0,0,,,,,,,,,,,,,," >> !{biosample}.csv
    fi

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
