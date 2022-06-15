# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

# Get variables

## Debug
IN_FILES = list("/hps/nobackup/birney/users/ian/Kiyosu_CC/final_tracks/novel_object/20220204_1416_R_q3.csv",
                "/hps/nobackup/birney/users/ian/Kiyosu_CC/final_tracks/novel_object/20220204_1416_R_q4.csv")

## True
IN_FILES = snakemake@input
OUT_FILE = snakemake@output[[1]]

# Read files and process

final_df = purrr::map(IN_FILES, function(IN_FILE){
    # read in file
    df = readr::read_csv(IN_FILE, col_types = c("iddddd"))
    # create tibble
    out = tibble::tibble(
        "path" = IN_FILE,
        "total_seconds" = max(df$seconds),
        "success_count" = df %>% 
            dplyr::filter(complete.cases(.)) %>%
            nrow(.),
        "frame_count" = nrow(df)
        ) %>%
        # get `sample` and `assay`
        tidyr::separate(path,
                        into = c(rep(NA, 8), "assay", "sample"),
                        sep = "/") %>%
        # remove .csv extension from `sample`
        dplyr::mutate(sample = sample %>%
            stringr::str_remove(".csv")) %>%
        # get proportion of success
        dplyr::mutate("prop_success" = success_count / frame_count )

    return(out)

}) %>% 
    # bind into single DF
    dplyr::bind_rows() %>%
    # separate `sample` into `date`, `time`, and `quadrant`
    tidyr::separate(sample,
                    into = c("date", "time", "tank_side", "quadrant"),
                    sep = "_") %>% 
    # re-create sample
    tidyr::unite(col = "sample",
                 date, time, tank_side,
                 sep = "_") %>% 
    # reorder columns
    dplyr::select(sample, quadrant, assay, everything()) %>%
    # order rows by `prop_success`
    dplyr::arrange(prop_success)

# Write to file

readr::write_csv(final_df, OUT_FILE)
