process RTGTOOLS_VCFEVAL {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::rtg-tools=3.12.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/rtg-tools:3.12.1--hdfd78af_0':
        'quay.io/biocontainers/rtg-tools:3.12.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(query_vcf), path(query_vcf_tbi)
    tuple path(truth_vcf), path(truth_vcf_tbi)
    path(truth_regions)
    path(sdf)

    output:
    tuple val(meta), path("*.txt"), emit: results
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def regions = truth_regions ? "--bed-regions=$truth_regions" : ""
    def truth_index = truth_vcf_tbi ? "" : "rtg index $truth_vcf"
    def query_index = query_vcf_tbi ? "" : "rtg index $query_vcf"

    """
    $truth_index
    $query_index

    rtg vcfeval \\
        $args \\
        --baseline=$truth_vcf \\
        $regions \\
        --calls=$query_vcf \\
        --output=$prefix \\
        --template=$sdf \\
        --threads=$task.cpus \\
        > ${prefix}_results.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rtg-tools: \$(echo \$(rtg version | head -n 1 | awk '{print \$4}'))
    END_VERSIONS
    """
}
