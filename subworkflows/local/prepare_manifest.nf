//
// Subworkflow: Prepare a manifest file for the specified pipeline.
//

include { PREPARE_GENERIC } from '../../modules/local/prepare_generic'

workflow PREPARE_MANIFEST {
    take:
        reads // channel: [ val(reads) ]

    main:
    ch_versions = Channel.empty() // Used to collect the software versions
    
    // Generic manifest file - this works for PHoeNIx and MycoSNP
    if (params.output_format == "generic" || params.output_format == "mycosnp" || params.output_format == "phoenix") {

        PREPARE_GENERIC ( 
            reads
        )
        ch_versions = ch_versions.mix(PREPARE_GENERIC.out.versions)
        PREPARE_GENERIC.out.manifest.set{ manifest } 
    }

    // Option to upload reads to a bucket for NCBI submissions
    // Read names are replaced with the names from the manifest file
    if(params.ncbi_bucket){
        println("Copying reads to bucket for NCBI uploads:")
        def ncbi_bucket_path = file(params.ncbi_bucket)
        manifest
            .splitCsv(header: true)
            .map { tuple(file(it.fastq_1).copyTo(ncbi_bucket_path.resolve(it.sample+"_R1.fastq.gz")), file(it.fastq_2).copyTo(ncbi_bucket_path.resolve(it.sample+"_R2.fastq.gz"))) }
    }
    


    emit:
    manifest = manifest // channel: [ manifest.* ]
    versions = ch_versions // channel: [ versions.yml ]
}
