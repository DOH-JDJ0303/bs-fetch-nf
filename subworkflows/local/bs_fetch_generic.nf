//
// Download samples and generate manifest in a generic format (works for MycoSNP and PHoeNIx)
//

include { BS_FETCH_BIOSAMPLE } from '../../modules/local/bs_fetch_biosample'
include { BS_FETCH_DATASET } from '../../modules/local/bs_fetch_dataset'
include { PREPARE_GENERIC } from '../../modules/local/prepare_generic'

workflow BS_FETCH_GENERIC {
    take:
    samples // channel: val(sample)

    main:

    if (params.batch_type == "biosample") {

        BS_FETCH_BIOSAMPLE (samples)

        BS_FETCH_BIOSAMPLE
            .out
            .reads
            .collect()
            .set { reads }
    }

    if (params.batch_type == "dataset") {
        
        BS_FETCH_DATASET (samples)
        BS_FETCH_DATASET
            .out
            .reads
            .collect()
            .set { reads }
    }

    PREPARE_GENERIC ( reads )

    emit:
    reads = reads
}
