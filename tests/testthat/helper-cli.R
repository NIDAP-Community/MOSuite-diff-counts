setup_cli_workspace <- function(prefix = "mosuite_diff_counts_test_") {
  workspace <- tempfile(prefix)
  dir.create(workspace)

  code_dir <- file.path(workspace, "code")
  data_dir <- file.path(workspace, "data")
  results_dir <- file.path(workspace, "results")
  dir.create(code_dir, recursive = TRUE)
  dir.create(data_dir, recursive = TRUE)
  dir.create(file.path(results_dir, "figures"), recursive = TRUE)
  dir.create(file.path(results_dir, "moo"), recursive = TRUE)

  repo_root <- normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    mustWork = TRUE
  )

  test_data_file <- file.path(repo_root, "tests", "data", "moo-filt.rds")

  expect_true(
    file.exists(test_data_file),
    info = paste("Test data file should exist at", test_data_file)
  )
  file.copy(test_data_file, file.path(data_dir, "moo.rds"), overwrite = TRUE)

  file.copy(
    file.path(repo_root, "code", "main.R"),
    file.path(code_dir, "main.R"),
    overwrite = TRUE
  )

  # Keep main.R behavior the same while pointing to this checkout's MOSuite package.
  main_copy <- file.path(code_dir, "main.R")
  main_lines <- readLines(main_copy)
  main_lines <- gsub(
    "devtools::load_all('/code/MOSuite')",
    sprintf(
      "devtools::load_all('%s')",
      file.path(repo_root, "code", "MOSuite")
    ),
    main_lines,
    fixed = TRUE
  )
  writeLines(main_lines, main_copy)

  list(
    workspace = workspace,
    code_dir = code_dir,
    results_dir = results_dir,
    repo_root = repo_root
  )
}

expect_outputs_created <- function(results_dir) {
  moo_path <- file.path(results_dir, "moo", "moo-diff.rds")

  expect_true(file.exists(moo_path), info = "Diff MOO output should be created")
  expect_true(
    file.info(moo_path)$size > 0,
    info = "Diff MOO output should be non-empty"
  )

  moo <- readr::read_rds(moo_path)
  expect_true(
    inherits(moo, "MOSuite::multiOmicDataSet"),
    info = "Output should be an S7 multiOmicDataSet object"
  )
  expect_true(
    "diff" %in% names(moo@analyses),
    info = "Output should have diff results in moo@analyses"
  )
}

common_cli_args <- c(
  "--covariates_colnames=Group",
  "--contrast_colname=Group",
  "--contrasts=B-A"
)
