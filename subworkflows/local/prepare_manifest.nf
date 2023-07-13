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
    }

    emit:
    versions = ch_versions // channel: [ versions.yml ]
}
