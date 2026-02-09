#!/usr/bin/env Rscript
library(argparse)
library(glue)
library(MOSuite)
library(readr)
library(stringr)
library(dplyr)

# set up capsule environment
setup_capsule_environment()

# parse CLI arguments
parser <- ArgumentParser()

parser$add_argument("--count_type", type = "character", default = "filt")
parser$add_argument(
  "--sub_count_type",
  type = "character",
  default = NULL,
  help = "Sub count type if count_type is a list"
)
parser$add_argument(
  "--sample_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for sample IDs"
)
parser$add_argument(
  "--feature_id_colname",
  type = "character",
  default = NULL,
  help = "Column name for feature IDs"
)
parser$add_argument(
  "--samples_to_include",
  type = "character",
  default = "",
  help = "Comma-separated list of samples to include"
)
parser$add_argument(
  "--covariates_colnames",
  type = "character",
  default = "Group",
  help = "Comma-separated list of covariate column names"
)
parser$add_argument(
  "--contrast_colname",
  type = "character",
  default = "Group",
  help = "Column containing group variables for DE"
)
parser$add_argument(
  "--contrasts",
  type = "character",
  default = "",
  help = "Contrasts in format group1-group2,group1-group3"
)
parser$add_argument(
  "--input_in_log_counts",
  type = "logical",
  default = FALSE,
  help = "Counts are already log2-transformed"
)
parser$add_argument(
  "--return_mean_and_sd",
  type = "logical",
  default = FALSE,
  help = "Return mean and SD in addition to DE estimates"
)
parser$add_argument(
  "--voom_normalization_method",
  type = "character",
  default = "quantile",
  help = "Normalization method for limma::voom"
)

args <- parser$parse_args()

# load multiOmicDataSet from data directory
moo <- load_moo_from_data_dir()

# validate required parameters
if (identical(args$covariates_colnames, "")) {
  stop("covariates_colnames is required and cannot be empty")
}
if (identical(args$contrasts, "")) {
  stop("contrasts is required and cannot be empty")
}

# run MOSuite
moo |>
  diff_counts(
    count_type = args$count_type,
    sub_count_type = args$sub_count_type,
    sample_id_colname = args$sample_id_colname,
    feature_id_colname = args$feature_id_colname,
    samples_to_include = parse_optional_vector(args$samples_to_include),
    covariates_colnames = parse_vector_with_default(
      args$covariates_colnames,
      "Group"
    ),
    contrast_colname = args$contrast_colname,
    contrasts = parse_optional_vector(args$contrasts),
    input_in_log_counts = args$input_in_log_counts,
    return_mean_and_sd = args$return_mean_and_sd,
    voom_normalization_method = args$voom_normalization_method
  ) |>
  write_rds(file.path(getOption("moo_plots_dir"), "..", "moo", "moo-diff.rds"))
