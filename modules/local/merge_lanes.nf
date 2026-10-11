process MERGE_LANES {
    label 'process_low'
    tag "${sample}_${read}"

    input:
    // reads: all lane files for one sample + one read direction, already sorted by lane
    tuple val(sample), val(read), path(reads, stageAs: 'input/*')

    output:
    tuple val(sample), val(read), path("${sample}_${read}_001.fastq.gz"), emit: reads
    path "versions.yml"                                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def files = reads instanceof List ? reads : [reads]
    def out   = "${sample}_${read}_001.fastq.gz"
    // gzip files can be concatenated directly; a single lane is just linked (no copy)
    def cmd   = files.size() == 1 ? "ln -s ${files[0]} ${out}" : "cat ${files.join(' ')} > ${out}"
    """
    ${cmd}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: \$(cat --version | head -n 1 | sed 's/.* //')
    END_VERSIONS
    """
}
