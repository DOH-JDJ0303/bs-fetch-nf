process BS_FETCH_FILE_ID {
    input:
    tuple val(id)
    label 'process_high'

    output:
    path "*.fastq.gz"       , emit: reads
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    bs download file \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -i !{id} \\
        -o ./

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
