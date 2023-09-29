process BS_FETCH_BIOSAMPLE {
    label 'process_low'
    tag "${biosample}"

    input:
    tuple val(biosample)

    output:
    path "*.fastq.gz"       , emit: reads
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    bs download biosample \\
        --api-server=!{params.api_server} \\
        --access-token=!{params.access_token} \\
        -n !{biosample} \\
        -o ./

    mv */*.fastq.gz ./

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
