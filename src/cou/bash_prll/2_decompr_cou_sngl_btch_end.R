# Introduction: Estimate VA content based on Wang et al.
# clear the console
cat("\f")
# ##@## PREAMBLE: Environment ####

#.rs.restartR()
# clear the environment
rm(list = ls())

# clear cache
gc(full=TRUE)
Sys.sleep(1)

# Imports: All the library imports go here

library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(decompr)
# library(foreach)
# library(doParallel)
library(conflicted)
# ##$##

# ##@## PREAMBLE: 2 Settings ####
NAME <- "R_aamne_decompr"
PROJECT <- "r_aamne_wwz"
PROJECT_DIR <- "/home/mmvvff_v1"
RAW_DATA <- "0_data/"
#PROJECT_DIR <- "/Volumes/hd_mvf_datapipes/data_processing/icio_nrr/"
#RAW_DATA <- "/Volumes/hd_mvf_datasets/data_raw/quant/1_large_datasets/oecd_datasets/"


# Set working directory The code below will traverse the path upwards until it
# finds the root folder of the project.

setwd(file.path(PROJECT_DIR, PROJECT))

# Set up pipeline folder if missing The code below will automatically create a
# pipeline folder for this code file if it does not exist.

if (dir.exists(file.path("empirical", "2_pipeline"))) {
  pipeline <- file.path("empirical", "2_pipeline", NAME)
} else {
  pipeline <- file.path("2_pipeline", NAME)
}

if (!dir.exists(pipeline)) {
  dir.create(pipeline)
  for (folder in c("out", "store", "tmp")) {
    dir.create(file.path(pipeline, folder))
  }
}
# ##$##

##### join and export

# ##@## collect estimates: decomp_aamne_wwz
setwd(file.path(PROJECT_DIR, PROJECT, pipeline, "store"))
decomp_aamne_wwz_data2load=list.files(pattern=paste0("decomp_aamne_[0-9]{4}_wwz.rds"))
decomp_aamne_wwz_list=lapply(decomp_aamne_wwz_data2load,readRDS)

# reset initial setup
setwd(file.path(PROJECT_DIR, PROJECT))

# combine df rowwise
decomp_aamne_wwz<-decomp_aamne_wwz_list%>%
  Reduce(f=bind_rows) %>%
  tibble::add_column(sctr_s_i=c("total"),.before="sctr_c_j")
glimpse(decomp_aamne_wwz)

saveRDS(decomp_aamne_wwz%>%
  ungroup() %>% tibble::add_column(updated=Sys.Date()),
  file=file.path(pipeline, "out","decomp_aamne_wwz_cou.rds"))

# ##$##
