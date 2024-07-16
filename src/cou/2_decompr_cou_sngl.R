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
library(progress)
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

func_getvarname <- function(variable, pattern_exclude = "") {
  # get variable name a character vector
  return(
    stringr::str_remove(deparse(substitute(variable)),
    pattern_exclude))
}

func_xstring <- function(original_string, char_insert="x") {
  # Concatenate the character and the original string
  new_string <- paste0(char_insert, original_string)
  return(new_string)
}

###### INITIATE LOOP
vctr_allyears<-as.character(c(2000:2013))
pb<-progress_bar$new(total=length(vctr_allyears))
pb$tick(0)
for(i in vctr_allyears){ # START of loop
Sys.sleep(1)
cat("\n")
print(i)
pb$tick()
cat("\n")
flush.console()


#i<-c("2010")

# ##@## Load data
countries_aamne <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_countries_",i,".rds"))
#
industries_aamne <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_industries_",i,".rds"))
#
aamne_z_i_matrix <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_z_",i,"_matrix.rds"))
#
aamne_f_i_matrix <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_f_",i,"_matrix.rds"))
#
aamne_go_i_vector <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_go_",i,"_vector.rds"))
#
aamne_va_i_vector <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_va_",i,"_vector.rds"))
#
aamne_gva_i_vector <- readRDS(paste0(file.path(
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_gva_",i,"_vector.rds"))

# ##$##

# ##@## implement decompr

# ##@## we generate vectors
decomp_aamne_i <- decompr::load_tables_vectors(
  #iot,
  x=aamne_z_i_matrix, # intermediate demand table
  y=aamne_f_i_matrix, # final demand table
  k=countries_aamne,
  i=industries_aamne,
  # Error: o supplied is different from rowSums(x) + rowSums(y).
  # Mean relative difference: 2.296809e-06
  # Interpretation: the gva vector from aamne is not identical to
  # calculation based on provided matrices
  # Solution: we estimate GO based on provided matrices
  # o = aamne_go_i_vector,
  # Error: v supplied is different from o - colSums(x).
  # Mean relative difference: 2.436384e-08
  # Interpretation: the gva vector from aamne is not identical to
  # GO less intermediate consumption [colSums(x)] based on provided matrices
  # Solution: we estimate gva based on provided matrices
  #v = aamne_gva_i_vector,
  null_inventory = FALSE
  )
# ##$##

#### Unit of analysis: COUNTRY-lEVEL
#### estimates where the source of VA is the entire economy;
#### useful for aggregate analysis

# ##@### VA-trade decomposition based on: decomp_aamne_i
decomp_aamne_i_wwz <- tibble::tibble(
  decompr::wwz(decomp_aamne_i, verbose = TRUE)) %>%
  tibble::add_column(year=factor(i)) %>%
  dplyr::relocate(year,.after=3) %>%
  dplyr::rename(
    cntry_c=Exporting_Country,
    sctr_c_j=Exporting_Industry,
    cntry_p=Importing_Country)
#glimpse(decomp_aamne_i_wwz)

saveRDS(decomp_aamne_i_wwz,
  file=paste0(
    file.path(pipeline, "store",""),
    "decomp_aamne_",i,"_wwz.rds"))

# ##$##

# ##$##

}

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
  file=file.path(pipeline, "out","decomp_aamne_wwz.rds"))

# ##$##
