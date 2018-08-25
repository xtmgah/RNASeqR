#' @title Ballgown analysis, TPM & Student's t-test analysis, DESeq2 analysis, edgeR analysis for RNA-Seq workflow in background
#'
#' @description This function will run differential analysis on ballgown, DESeq2 and edgeR. TPM values will be converted from ballgown FPKM values, and T-test will be made to calculate pvalue.
#' This function do following things :
#' 1. ballgown analysis
#'    Raw reads are normalized into FPKM values
#'    The main statistic test in ballgown is paramatic F-test comparing nested linear models
#' 2. TPM & Student's t-test analysis
#'    TPM normalization is calculated from the FPKM values produced by ballgown.
#'    Independent sample t-test is used with TPM values as input. P-values will be produced after t-test. Fold change values are calculated by the formula : "average TPM experiment group values divide average TPM control group values".
#' 3. DESeq2 analysis
#'    Median of rations normalization(MRN) is used in DESeq2 for raw counts normalization. Sequencing depth and RNA composition is taken into consideration is this normalization method.
#'    The main statistic test in DESeq2 is negative binomial distribution.
#' 4. edgeR analysis
#'    Raw reads are normalized by TMM and library size. (run \code{calcNormFactors()} to get a DGEList, and then run \code{cpm()} on that DGEList)
#'    The main statistic test in edgeR is trimmed mean of M-values(TMM).
#' If you want to run differential analysis on ballgown, TPM normalization, DESeq2, edgeR for the following RNA-Seq workflow in R shell, please see \code{RNASeqDifferentialAnalysis()} function.
#'
#' @param RNASeqWorkFlowParam S4 object instance of experiment-related parameters
#' @param ballgown.pval Default \code{0.05}. Set the threshold of ballgown p-value to filter out differential expressed gene.
#' @param ballgown.log2FC Default \code{1}. Set the threshold of ballgown log2 fold change to filter out differential expressed gene.
#' @param TPM.pval Default \code{0.05}. Set the threshold of TPM & student t-test p-value to filter out differential expressed gene.
#' @param TPM.log2FC Default \code{1}. Set the threshold of TPM & student t-test log2 fold change to filter out differential expressed gene.
#' @param DESeq2.pval Default \code{0.05}. Set the threshold of DESeq2 p-value to filter out differential expressed gene.
#' @param DESeq2.log2FC Default \code{1}. Set the threshold of DESeq2 log2 fold change to filter out differential expressed gene.
#' @param edgeR.pval Default \code{0.05}. Set the threshold of edgeR p-value to filter out differential expressed gene.
#' @param edgeR.log2FC Default \code{1}. Set the threshold of edgeR log2 fold change to filter out differential expressed gene.
#' @param run Default value is \code{TRUE}. If \code{TRUE}, 'Rscript/Environment_Set.R' will be created and executed. The output log will be stored in 'Rscript_out/Environment_Set.Rout'.
#' If \code{False}, 'Rscript/Environment_Set.R' will be created without executed.
#' @param check.s4.print Default \code{TRUE}. If \code{TRUE}, the result of checking \code{RNASeqWorkFlowParam} will be reported in 'Rscript_out/Environment_Set.Rout'. If \code{FALSE}, the result of checking \code{RNASeqWorkFlowParam} will not be in 'Rscript_out/Environment_Set.Rout'
#'
#' @return None
#' @export
#' @author Kuan-Hao Chao
#' @examples
#' \dontrun{
#' input_file_dir <- system.file(package = "RNASeqWorkflow", "exdata")
#' exp <- RNASeqWorkFlowParam(path.prefix = "/tmp/", input.path.prefix = input_file_dir, genome.name = "hg19", sample.pattern = "SRR[0-9]",
#'                            experiment.type = "two.group", main.variable = "treatment", additional.variable = "cell")
#' RNASeqEnvironmentSet_CMD(RNASeqWorkFlowParam = exp)}
RNASeqDifferentialAnalysis_CMD <- function(RNASeqWorkFlowParam, ballgown.pval = 0.05, ballgown.log2FC = 1, TPM.pval = 0.05, TPM.log2FC = 1, DESeq2.pval = 0.1, DESeq2.log2FC = 1, edgeR.pval = 0.05, edgeR.log2FC = 1, run = TRUE, check.s4.print = TRUE) {
  # check input param
  CheckS4Object(RNASeqWorkFlowParam, check.s4.print)
  CheckOperatingSystem(FALSE)
  path.prefix <- RNASeqWorkFlowParam@path.prefix
  genome.name <- RNASeqWorkFlowParam@genome.name
  sample.pattern <- RNASeqWorkFlowParam@sample.pattern
  independent.variable <- RNASeqWorkFlowParam@independent.variable
  control.group <- RNASeqWorkFlowParam@control.group
  experiment.group <- RNASeqWorkFlowParam@experiment.group
  fileConn<-file(paste0(path.prefix, "Rscript/Differential_Analysis.R"))
  first <- "library(RNASeqWorkflow)"
  second <- paste0("RNASeqDifferentialAnalysis(path.prefix = '", path.prefix, "', genome.name = '", genome.name, "', sample.pattern = '", sample.pattern, "', independent.variable = '",independent.variable,  "', control.group = '",control.group,  "', experiment.group = '",experiment.group, "', ballgown.log2FC = ", ballgown.log2FC, ", ballgown.pval = ", ballgown.pval, ")")
  writeLines(c(first, second), fileConn)
  close(fileConn)
  cat(paste0("\u2605 '", path.prefix, "Rscript/Differential_Analysis.R' has been created.\n"))
  if (run) {
    system2(command = 'nohup', args = paste0("R CMD BATCH ", path.prefix, "Rscript/Differential_Analysis.R ", path.prefix, "Rscript_out/Differential_Analysis.Rout"), stdout = "", wait = FALSE)
    cat(paste0("\u2605 Tools are installing in the background. Check current progress in '", path.prefix, "Rscript_out/Differential_Analysis.Rout'\n\n"))
  }
}

#' @title Ballgown analysis, TPM & Student's t-test analysis, DESeq2 analysis, edgeR analysis for RNA-Seq workflow in R shell
#'
#' @description This function will run differential analysis on ballgown, DESeq2 and edgeR. TPM values will be converted from ballgown FPKM values, and T-test will be made to calculate pvalue.
#' It is strongly advised to run \code{RNASeqDifferentialAnalysis_CMD()} directly. Running \code{RNASeqDifferentialAnalysis_CMD()} will create 'Differential_Analysis.Rout' file in 'Rscript_out/' directory.
#' This function do following things :
#' 1. ballgown analysis
#'    Raw reads are normalized into FPKM values
#'    The main statistic test in ballgown is paramatic F-test comparing nested linear models
#' 2. TPM & Student's t-test analysis
#'    TPM normalization is calculated from the FPKM values produced by ballgown.
#'    Independent sample t-test is used with TPM values as input. P-values will be produced after t-test. Fold change values are calculated by the formula : "average TPM experiment group values divide average TPM control group values".
#' 3. DESeq2 analysis
#'    Median of rations normalization(MRN) is used in DESeq2 for raw counts normalization. Sequencing depth and RNA composition is taken into consideration is this normalization method.
#'    The main statistic test in DESeq2 is negative binomial distribution.
#' 4. edgeR analysis
#'    Raw reads are normalized by TMM and library size. (run \code{calcNormFactors()} to get a DGEList, and then run \code{cpm()} on that DGEList)
#'    The main statistic test in edgeR is trimmed mean of M-values(TMM).
#' If you want to run differential analysis on ballgown, TPM normalization, DESeq2, edgeR for the following RNA-Seq workflow in background, please see \code{RNASeqDifferentialAnalysis()} function.
#'
#' @param path.prefix path prefix of 'gene_data/', 'RNASeq_bin/', 'RNASeq_results/', 'Rscript/' and 'Rscript_out/' directories
#' @param genome.name variable of genome name defined in this RNA-Seq workflow (ex. genome.name.fa, genome.name.gtf)
#' @param sample.pattern  regular expression of raw fastq.gz files under 'input_files/raw_fastq.gz'
#' @param independent.variable independent variable for the biological experiment design of two-group RNA-Seq workflow
#' @param control.group group name of the control group
#' @param experiment.group group name of the experiment group
#' @param ballgown.pval Default \code{0.05}. Set the threshold of ballgown p-value to filter out differential expressed gene.
#' @param ballgown.log2FC Default \code{1}. Set the threshold of ballgown log2 fold change to filter out differential expressed gene.
#' @param TPM.pval Default \code{0.05}. Set the threshold of TPM & student t-test p-value to filter out differential expressed gene.
#' @param TPM.log2FC Default \code{1}. Set the threshold of TPM & student t-test log2 fold change to filter out differential expressed gene.
#' @param DESeq2.pval Default \code{0.05}. Set the threshold of DESeq2 p-value to filter out differential expressed gene.
#' @param DESeq2.log2FC Default \code{1}. Set the threshold of DESeq2 log2 fold change to filter out differential expressed gene.
#' @param edgeR.pval Default \code{0.05}. Set the threshold of edgeR p-value to filter out differential expressed gene.
#' @param edgeR.log2FC Default \code{1}. Set the threshold of edgeR log2 fold change to filter out differential expressed gene.
#'
#' @return None
#' @export
#' @author Kuan-Hao Chao
#' @examples
#' \dontrun{
#' input_file_dir <- system.file(package = "RNASeqWorkflow", "exdata")
#' exp <- RNASeqWorkFlowParam(path.prefix = "/tmp/", input.path.prefix = input_file_dir, genome.name = "hg19", sample.pattern = "SRR[0-9]",
#'                            experiment.type = "two.group", main.variable = "treatment", additional.variable = "cell")
#' RNASeqEnvironmentSet_CMD(RNASeqWorkFlowParam = exp)}
RNASeqDifferentialAnalysis <- function(path.prefix, genome.name, sample.pattern, independent.variable, control.group, experiment.group, ballgown.pval = 0.05, ballgown.log2FC = 1, TPM.pval = 0.05, TPM.log2FC = 1, DESeq2.pval = 0.1, DESeq2.log2FC = 1, edgeR.pval = 0.05, edgeR.log2FC = 1) {
  CheckOperatingSystem(FALSE)
  PreRNASeqDifferentialAnalysis(path.prefix = path.prefix, sample.pattern = sample.pattern)
  if (file.exists(paste0(path.prefix, "Rscript_out/Raw_Read_Process.Rout"))) {
    Hisat2ReportAssemble(path.prefix, genome.name, sample.pattern)
  }
  cat("\u2618\u2618\u2618\u2618\u2618\u2618\u2618\u2618  Start 'ballgown', 'DESeq2' 'edgeR' analyses  \u2618\u2618\u2618\u2618\u2618\u2618\u2618\u2618\n")
  BallgownAnalysis(path.prefix, genome.name, sample.pattern, independent.variable, control.group, experiment.group, ballgown.pval, ballgown.log2FC)
  TPMNormalizationAnalysis(path.prefix, genome.name, sample.pattern, independent.variable, control.group, experiment.group, TPM.pval, TPM.log2FC)
  raw.read.avail <- RawReadCountAvailability(path.prefix)
  if (raw.read.avail) {
    DESeq2RawCountAnalysis(path.prefix, independent.variable,  control.group, experiment.group, DESeq2.pval, DESeq2.log2FC)
    edgeRRawCountAnalysis(path.prefix, independent.variable, control.group, experiment.group, edgeR.pval, edgeR.log2FC)
  }
  PostRNASeqDifferentialAnalysis(path.prefix = path.prefix, sample.pattern = sample.pattern)
}


PreRNASeqDifferentialAnalysis <- function(path.prefix, sample.pattern) {
  cat("\u269C\u265C\u265C\u265C RNASeqDifferentialAnalysis()' environment pre-check ...\n")
  validity <- TRUE
  if (!isTRUE(validity)) {
    stop("RNASeqDifferentialAnalysis() environment ERROR")
  }
  cat("(\u2714) : RNASeqDifferentialAnalysis() pre-check is valid\n\n")
}

PostRNASeqDifferentialAnalysis <- function(path.prefix, sample.pattern) {
  cat("\u269C\u265C\u265C\u265C RNASeqDifferentialAnalysis()' environment post-check ...\n")
  validity <- TRUE
  if (!isTRUE(validity)) {
    stop("RNASeqDifferentialAnalysis() post-check ERROR")
  }
  cat("(\u2714) : RNASeqDifferentialAnalysis() post-check is valid\n\n")
  cat(paste0("\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\n"))
  cat(paste0("\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605 Success!! \u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\n"))
  cat(paste0("\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\n"))
}