//
// Subworkflow: Download reads from Illumina BaseSpace using various inputs
//

include { BS_FETCH_BIOSAMPLE } from '../../modules/local/bs_fetch_biosample'
include { SUMMARIZE_IDS      } from '../../modules/local/summarize_ids'
include { BS_FETCH_FILE_ID   } from '../../modules/local/bs_fetch_file_id'
include { MERGE_LANES        } from '../../modules/local/merge_lanes'

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
        ch_versions = ch_versions.mix(BS_FETCH_BIOSAMPLE.out.versions.first())

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

    // Download by file ID (one task per file, i.e. per lane per read)
    BS_FETCH_FILE_ID (
        ch_input
    )
    ch_versions = ch_versions.mix(BS_FETCH_FILE_ID.out.versions.first())

    // Group lane files by sample and read direction: [ sample, 'R1', [ L001, L002, ... ] ]
    BS_FETCH_FILE_ID
        .out
        .reads
        .flatten()
        .map { fq ->
            // Illumina naming: <sample>[_S<n>][_L<lane>]_R<1|2>[_001].fastq.gz
            def m = fq.name =~ /^(.+?)(?:_S\d+)?(?:_L\d+)?_(R[12])(?:_\d+)?\.f(?:ast)?q\.gz$/
            if (!m.matches()) {
                error "Cannot determine sample name / read direction from '${fq.name}'. Expected <sample>_S<n>_L<lane>_R<1|2>_001.fastq.gz"
            }
            [ m.group(1), m.group(2), fq ]
        }
        .groupTuple(by: [0, 1])
        // sort by file name so lanes are concatenated in the same order for R1 and R2 (keeps pairs in sync)
        .map { sample, read, fqs -> [ sample, read, fqs.sort(false) { it.name } ] }
        .set { ch_lanes }

    //
    // MODULE: Combine lanes into a single file per read direction
    //
    MERGE_LANES (
        ch_lanes
    )
    ch_versions = ch_versions.mix(MERGE_LANES.out.versions.first())

    MERGE_LANES
        .out
        .reads
        .map { sample, read, fq -> fq }
        .collect()
        .set { reads }

    emit:
    reads    = reads // channel: [ val(reads) ]
    versions = ch_versions // channel: [ versions.yml ]
}
