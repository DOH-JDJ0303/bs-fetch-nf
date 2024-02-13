process SUMMARIZE_IDS {
    label 'process_low'

    input:
    path files
    

    output:
    path "bs-contents.csv", emit: summary
    
    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    echo "biosample,file_id" > bs-contents.csv
    cat !{files} >> bs_contents.csv
    '''
}
