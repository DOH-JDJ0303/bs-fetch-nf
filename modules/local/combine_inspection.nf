process COMBINE_INSPECTION {
    input:
    path reports

    output:
    path "bs_inspect.csv", emit: manifest

    when:
    task.ext.when == null || task.ext.when

    shell: // This script is bundled with the pipeline, in nf-core/bsfetch/bin/
    '''
    # create header
    header="BiosampleName,FileNumber,TotalFiles,FileId,Category,ContentType,DateCreated,DateModified,ETag,Href,HrefContent,IsArchived,Name,Path,Size,UploadStatus"
    echo ${header} > bs_inspect.csv

    # combine reports
    cat !{reports} | grep -v "${header}" >> bs_inspect.csv
    '''
}
