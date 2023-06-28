process PREPARE_GENERIC {
    input:
    val reads

    output:
    path "manifest.csv", emit: manifest
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    prepare_generic.sh "!{reads}" "!{params.outdir}"

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        prepare_generic: $( prepare_generic.sh --version | tr -d '\n\t\r ')
    '''
}
