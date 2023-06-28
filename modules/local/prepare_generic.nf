process PREPARE_GENERIC {
    publishDir "$params.outdir"
    container "ubuntu:jammy"

    input:
    val reads

    output:
    path 'manifest.csv'

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    bash prepare_mycosnp.sh "!{reads}" "!{params.outdir}"
    '''
}
