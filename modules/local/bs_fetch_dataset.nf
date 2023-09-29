process BS_FETCH_DATASET {
    label 'process_low'
    tag "${dataset}"

    input:
    tuple val(dataset)

    output:
    path "*.fastq.gz"       , emit: reads
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    bs download dataset \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{dataset} \\
        -o ./

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
