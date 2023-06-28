//
// Subworkflow: Download samples and generate manifest in a generic format (works for MycoSNP and PHoeNIx)
//

include { BS_FETCH_BIOSAMPLE } from '../../modules/local/bs_fetch_biosample'
include { BS_FETCH_DATASET } from '../../modules/local/bs_fetch_dataset'

workflow FETCH_READS {
    take:
        samples // channel: val(sample)

    main:
    ch_versions = Channel.empty() // Used to collect the software versions
    if (params.batch_type == "biosample") {
        BS_FETCH_BIOSAMPLE (
            samples
        )
        ch_versions = ch_versions.mix(BS_FETCH_BIOSAMPLE.out.versions)

        BS_FETCH_BIOSAMPLE
            .out
            .reads
            .collect()
            .set { reads }
    }

    if (params.batch_type == "dataset") {
        
        BS_FETCH_DATASET (
            samples
        )
        ch_versions = ch_versions.mix(BS_FETCH_DATASET.out.versions)

        BS_FETCH_DATASET
             .out
             .reads
             .collect()
             .set { reads }
    }

    emit:
    reads    = reads // channel: [ val(reads) ]
    versions = ch_versions // channel: [ versions.yml ]
}
