process BS_FETCH_DATASET {
    container 'theiagen/basespace_cli:1.2.1'
    publishDir "$params.outdir/reads"

    input:
    tuple val(dataset)

    output:
    tuple file('*.fastq.gz'), emit: reads

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    bs --api-server=!{params.api_server} --access-token=!{params.access_token} download dataset -n !{dataset} -o ./
    '''
}
