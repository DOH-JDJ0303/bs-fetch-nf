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
    # get biosample file content as YAML (includes DateCreated for each file)
    bs content biosample \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{biosample} \\
        --format yaml \\
        > content.yaml

    # parse YAML -> biosample,file_id,file_name,date_created (FASTQs only)
    awk -v s="!{biosample}" '
        function flush() {
            if (id != "" && name ~ /\\.f(ast)?q\\.gz$/) print s "," id "," name "," date
            id = ""; name = ""; date = ""
        }
        /^- / { flush(); sub(/^- /, "  ") }
        {
            line = $0; sub(/^ +/, "", line)
            key = line; sub(/:.*/, "", key)
            val = line; sub(/^[^:]*: */, "", val); gsub(/"/, "", val)
            if (key == "Id") id = val
            else if (key == "Name") name = val
            else if (key == "DateCreated") date = val
        }
        END { flush() }
    ' content.yaml > !{biosample}.csv

    if [ ! -s !{biosample}.csv ]
    then
        echo "ERROR: no FASTQ files found for biosample '!{biosample}'" >&2
        exit 1
    fi

    # keep the newest file for each lane + read (e.g. L001_R1), so re-sequenced lanes
    # replace older ones. The _S<n>_ index is ignored because it can differ between runs.
    # sort: key, then DateCreated (newest first), then file ID (highest first) as a tie-breaker
    awk -F ',' '{ k = $3; sub(/_S[0-9]+_/, "_", k); print k "," $4 "," $2 "," $2 "," $3 "," $4 }' !{biosample}.csv \\
        | LC_ALL=C sort -t ',' -k1,1 -k2,2r -k3,3nr \\
        | awk -F ',' '!seen[$1]++' \\
        | cut -f 4- -d ',' \\
        > newest.csv

    # log what was dropped (visible in .command.err)
    n_all=$(wc -l < !{biosample}.csv)
    n_new=$(wc -l < newest.csv)
    if [ ${n_all} -gt ${n_new} ]
    then
        echo "!{biosample}: kept ${n_new} newest of ${n_all} FASTQ files:" >&2
        cat newest.csv >&2
    fi

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '[:space:]')
    END_VERSIONS
    '''
}
