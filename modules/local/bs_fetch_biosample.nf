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
    # get biosample file content
    bs content biosample \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{biosample} \\
        > content.txt
    
    # extract file IDs & add biosample name
    cat content.txt | grep '.gz' | cut -f 2 -d ' ' | tr -d '\t ' | awk -v s=!{biosample} '{print a","$0}' > !{biosample}.csv

    # extract newest IDs
    cat !{biosample}.csv | cut -f 2 -d ',' | sed -n 1,2p > newest.csv

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
