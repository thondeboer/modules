process MEME_FINDMOTIFS {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/meme:5.5.4--pl5321hda358d9_0' :
        'biocontainers/meme:5.5.4--pl5321hda358d9_0' }"


    input:
    tuple val(meta), path(fasta)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("meme_out/*.eps"), emit: logoeps
    //tuple val(meta), path("meme_out/*.png"), emit: logopng
    tuple val(meta), path("meme_out/*.txt"), emit: resulttxt
    tuple val(meta), path("meme_out/*.xml"), emit: resultxml
    tuple val(meta), path("meme_out/*.html"), emit: htmlreport
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gzip -cd $fasta > fasta_uncompressed.fa
    meme \\
        $args \\
        fasta_uncompressed.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        meme: \$(meme -version)
    END_VERSIONS
    """
}
