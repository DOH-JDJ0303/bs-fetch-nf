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
    # create file with biosample name - required input for bs-inspect.sh script
    echo !{biosample} > BIOSAMPLE

    # run bs-inspect.sh script
    bs-inspect.sh \
        BIOSAMPLE \
        !{params.access_token} \
        !{params.api_server}

    # rename output
    mv bs_inspect.csv !{biosample}.csv

    cat <<-END_VERSIONS > versions.yml
    "!{task.process}":
        bs-cli: $( bs -V | cut -f 2 -d ' ' | tr -d '\n\t\r ')
    '''
}
