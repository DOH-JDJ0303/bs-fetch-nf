process BS_FETCH_BIOSAMPLE {
    label 'process_low'
    tag "${biosample}"

    input:
    val biosample

    output:
    path "${biosample}.csv",emit: all_ids
    path "newest.csv",      emit: newest_ids
    path "versions.yml",    emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    # get biosample file content (all files from all datasets - used for the summary)
    bs content biosample \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{biosample} \\
        > content.txt

    # extract file IDs & add biosample name
    { grep '.gz' content.txt || true; } | cut -f 2 -d ' ' | tr -d '\t ' | awk -v s=!{biosample} '{print s","$0}' > !{biosample}.csv

    # resolve the biosample ID (exact match, unlike the name filter on 'bs list dataset')
    biosample_id=$(bs get biosample \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{biosample} \\
        --terse)

    # list datasets for this biosample, newest first
    bs list dataset \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        --input-biosample-id=${biosample_id} \\
        -f csv -F Id -F DateCreated \\
        | { grep -v '^Id,' || true; } \\
        | sort -t ',' -k 2,2 -r \\
        | cut -f 1 -d ',' \\
        > datasets.txt

    # take ALL FASTQ file IDs (every lane, R1 and R2) from the newest dataset that contains FASTQs
    touch newest.csv
    for ds in $(cat datasets.txt)
    do
        bs content dataset \\
            --api-server=!{params.api_server} \\
            --access-token=!{params.access_token} \\
            -i ${ds} \\
            --extension=fastq.gz \\
            --terse \\
            > newest.csv || true
        if [ -s newest.csv ]; then break; fi
    done

    if [ ! -s newest.csv ]
    then
        echo "ERROR: no FASTQ files found in any dataset for biosample '!{biosample}'" >&2
        exit 1
    fi

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '[:space:]')
    END_VERSIONS
    '''
}
