#!/usr/bin/env nextflow
import java.nio.file.Paths


//params.output_folder = '/data/dperera/outputs/test_docker'
//params.bam_folder = '/data/dperera/from_s3/200817_M02558_0388_000000000-J6PKJ'

bam_folder="$projectDir/$params.bam_folder"
loci_file_msisensor = "$projectDir/$params.loci_file_msisensor"
loci_file_mantis = file(params.loci_file_mantis)

normal_bam = "$projectDir/$params.normal_bam"
normal_bai = "$projectDir/$params.normal_bai"

genome_fa = file(params.genome_fa)
genome_fa_fai = file(params.genome_fa_fai)

// Read in bam files
bam_paths = Paths.get(bam_folder,"/DNA*/DNA*[0-9].hardclipped.bam")
bam_files = Channel.fromPath(bam_paths)

// Read in bai files
bai_paths = Paths.get(bam_folder,"/DNA*/DNA*[0-9].hardclipped.bam.bai")
bai_files = Channel.fromPath(bai_paths)


// The bam and bai files are used by both callers, so we split the channel into two:
bam_files.into {bam_files_msisensor; bam_files_mantis}
bai_files.into {bai_files_msisensor; bai_files_mantis}

/**************
** MSIsensor **
***************/

process run_mantis{

    publishDir params.output_folder

    input:
        file tumour_bam from bam_files_msisensor
	file tumour_bai from bai_files_msisensor
        path normal_bam
        path normal_bai
	path genome_fa
	path genome_fa_fai
	path loci_file_msisensor
        path loci_file_mantis
    output:
        file "${tumour_bam.baseName}.msisensor" into msisensor_outputs

    """
    msisensor msi -d $loci_file_msisensor -n $normal_bam -t ${tumour_bam} -o ${tumour_bam.baseName}.msisensor
    """
}




