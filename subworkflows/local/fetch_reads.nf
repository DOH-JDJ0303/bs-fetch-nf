//
// Subworkflow: Download reads from Illumina BaseSpace using various inputs
//

include { BS_FETCH_BIOSAMPLE } from '../../modules/local/bs_fetch_biosample'
include { SUMMARIZE_IDS      } from '../../modules/local/summarize_ids'
include { BS_FETCH_FILE_ID   } from '../../modules/local/bs_fetch_file_id'

workflow FETCH_READS {
    take:
        samples // channel: val(sample)

    main:
    ch_versions = Channel.empty() // Used to collect the software versions

    // Set the samplesheet to the default input. This is used if file IDs are supplied. Otherwise, file IDs are determined using the other approaches.
    ch_input = samples

    // Determine newest file IDs for each biosample name
    if (params.input_format == "biosample") {
        BS_FETCH_BIOSAMPLE (
            samples
        )
        ch_versions = ch_versions.mix(BS_FETCH_BIOSAMPLE.out.versions)

        // Update input with file ids
        BS_FETCH_BIOSAMPLE
            .out
            .newest_ids
            .splitCsv(header: false)
            .map{ id -> id.get(0) }
            .set { ch_input }

        // Create summary of all file IDs
        SUMMARIZE_IDS(
            BS_FETCH_BIOSAMPLE.out.all_ids.collect()
        )
    }

    // Download by file ID
    BS_FETCH_FILE_ID (
        ch_input
    )
    ch_versions = ch_versions.mix(BS_FETCH_FILE_ID.out.versions)

    BS_FETCH_FILE_ID
        .out
        .reads
        .collect()
        .set { reads }

    emit:
    reads    = reads // channel: [ val(reads) ]
    versions = ch_versions // channel: [ versions.yml ]
}
