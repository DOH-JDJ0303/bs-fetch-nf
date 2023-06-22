//
// Download samples and format for MycoSNP
//

include { BS_FETCH_SAMPLE } from '../../modules/local/bs_fetch_sample'
include { PREPARE_MYCOSNP } from '../../modules/local/prepare_mycosnp'

workflow BS_FETCH_MYCOSNP {
    take:
    samples // channel: val(sample)

    main:
    BS_FETCH_SAMPLE ( samples )

    if (params.batch_type == "sample") {

        BS_FETCH_SAMPLE
            .out
            .reads
            .collect()
            .set { reads }
    }

    PREPARE_MYCOSNP ( reads )

    PREPARE_MYCOSNP
        .out
        .view { it }

    emit:
    reads = BS_FETCH_SAMPLE.out.reads
}
