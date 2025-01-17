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

# ##@## CODES | VECTORS: codes and vectors for sectors

# ##@## DATA: sector codes

#codes_sector_aamne_all <- read_csv(file.path( "0_data",
#  "codes_sector_oecd_aamneV18_classification.csv"))
#glimpse(codes_sector_aamne_all)

codes_sector_aamne_all <- read_csv(file.path( "0_data",
  "codes_sector_oecd_aamneV23_classification.csv"))
#glimpse(codes_sector_aamne_all)

# ##$##

# ##@## VECTORS: sector_codes according to sectors and segments ####
# we create a vector of sectors that distinguish between NRR-based sectors and
# manufacturing sectors we use the sector codes of icio (Eurostat based on ISIC
# Rev. 4)
# we create a vector of codes of nrr vc, sectors and segments
# nrrprd  producers
codes_sector_aamne_all_nrrprd_vc <- dplyr::filter(codes_sector_aamne_all,
  nrr_vc_prdcrs==1)
codes_nrrprd_vc <- paste(codes_sector_aamne_all_nrrprd_vc$sector_code)
unique(codes_nrrprd_vc)

codes_sector_aamne_all_nrrprd_upstrm <- dplyr::filter(codes_sector_aamne_all,
  nrr_upstrm_prdcrs==1)
codes_nrrprd_upstrm <- paste(codes_sector_aamne_all_nrrprd_upstrm$sector_code)
unique(codes_nrrprd_upstrm)

codes_sector_aamne_all_nrrprd_dwnstrm <- dplyr::filter(codes_sector_aamne_all,
  nrr_dwnstrm_prdcrs==1)
codes_nrrprd_dwnstrm <- paste(codes_sector_aamne_all_nrrprd_dwnstrm$sector_code)
unique(codes_nrrprd_dwnstrm)

# suppliers
codes_sector_aamne_all_tradables_mx <- dplyr::filter(codes_sector_aamne_all,
  tradables_mx == 1)
codes_tradables_mx <- paste(codes_sector_aamne_all_tradables_mx$sector_code)
unique(codes_tradables_mx)

codes_sector_aamne_all_tradables_sx <- dplyr::filter(codes_sector_aamne_all,
  tradables_sx == 1)
codes_tradables_sx <- paste(codes_sector_aamne_all_tradables_sx$sector_code)
unique(codes_tradables_sx)

codes_tradables_umxsx <- setdiff(union(codes_tradables_mx,codes_tradables_sx), codes_nrrprd_vc)

# manfucaturing users of end-products
codes_sector_aamne_all_mnfctrng_usrs <- dplyr::filter(codes_sector_aamne_all,
  mnfctrng_users==1)
codes_mnfctrng_usrs <- paste(codes_sector_aamne_all_mnfctrng_usrs$sector_code)
unique(codes_mnfctrng_usrs)


# manufacturing producers
codes_sector_aamne_all_mnfctrng_all <- dplyr::filter(codes_sector_aamne_all,
  mnfctrng_prdcrs == 1)
codes_mnfctrng_gvc <- paste(codes_sector_aamne_all_mnfctrng_all$sector_code)
unique(codes_mnfctrng_gvc)

codes_sector_aamne_all_mnfctrng_apprl <- dplyr::filter(codes_sector_aamne_all,
  apparel_prdcrs == 1)
codes_mnfctrng_apprl <- paste(codes_sector_aamne_all_mnfctrng_apprl$sector_code)
unique(codes_mnfctrng_apprl)

codes_sector_aamne_all_mnfctrng_atmtv <- dplyr::filter(codes_sector_aamne_all,
  autmtv_prdcrs == 1)
codes_mnfctrng_atmtv <- paste(codes_sector_aamne_all_mnfctrng_atmtv$sector_code)
unique(codes_mnfctrng_atmtv)

codes_sector_aamne_all_mnfctrng_elctrncs <- dplyr::filter(codes_sector_aamne_all,
  elctrncs_prdcrs == 1)
codes_mnfctrng_elctrncs <- paste(codes_sector_aamne_all_mnfctrng_elctrncs$sector_code)
unique(codes_mnfctrng_elctrncs)

# tech intensity
codes_sector_aamne_all_techrnd_highmed <- dplyr::filter(codes_sector_aamne_all,
  techrnd_highmed == 1)
codes_techrnd_highmed <- paste(codes_sector_aamne_all_techrnd_highmed $sector_code)
unique(codes_techrnd_highmed)

codes_tradables_techrnd<-intersect(codes_techrnd_highmed,codes_tradables_umxsx)
# ##$##

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

##### join and export

vctr_sctr_aggregates <- tibble(
  codes = c(
    list(codes_tradables_umxsx),
    list(codes_nrrprd_upstrm),
    list(codes_nrrprd_dwnstrm),
    list(codes_tradables_techrnd)),
  names = c(
    func_getvarname(codes_tradables_umxsx, "codes_"),
    func_getvarname(codes_nrrprd_upstrm, "codes_"),
    func_getvarname(codes_nrrprd_dwnstrm, "codes_"),
    func_getvarname(codes_tradables_techrnd, "codes_"))
  )

# ##@## collect estimates for sectoral aggregates included as source of VA

print("started: sectoral aggregates included as source of VA")

for (idx in seq(nrow(vctr_sctr_aggregates))) {
  # names for included
  name_sctr_aggregates <- vctr_sctr_aggregates[idx,]$"names"[[1]]

  # ##@## decomp_aamne_name_sctr_aggregates_wwz
  setwd(file.path(PROJECT_DIR, PROJECT, pipeline, "store"))
  decomp_aamne_name_sctr_aggregates_wwz_data2load=list.files(pattern=paste0("decomp_aamne_",name_sctr_aggregates,"_[0-9]{4}_wwz.rds"))
  decomp_aamne_name_sctr_aggregates_wwz_list=lapply(decomp_aamne_name_sctr_aggregates_wwz_data2load,readRDS)

  # reset initial setup
  setwd(file.path(PROJECT_DIR, PROJECT))

  # combine df rowwise
  decomp_aamne_name_sctr_aggregates_wwz<-decomp_aamne_name_sctr_aggregates_wwz_list%>%
    Reduce(f=bind_rows) %>%
    tibble::add_column(sctr_c_i=name_sctr_aggregates,.before="sctr_c_j")
  #glimpse(decomp_aamne_name_sctr_aggregates_wwz)

  saveRDS(decomp_aamne_name_sctr_aggregates_wwz %>%
    ungroup() %>% tibble::add_column(updated=Sys.Date()),
    file=file.path(pipeline, "out", paste0("decomp_aamne_",name_sctr_aggregates,"_wwz.rds")))
  # ##$##
}

print("finished: sectoral aggregates included as source of VA")

# ##$##

# ##@## collect estimates for sectoral aggregates excluded as source of VA

print("started: sectoral aggregates excluded as source of VA")

for (idx in seq(nrow(vctr_sctr_aggregates))) {
  # names for excluded
  name_sctr_aggregates <- func_xstring(vctr_sctr_aggregates[idx,]$"names"[[1]])

  # ##@## decomp_aamne_name_sctr_aggregates_wwz
  setwd(file.path(PROJECT_DIR, PROJECT, pipeline, "store"))
  decomp_aamne_name_sctr_aggregates_wwz_data2load=list.files(pattern=paste0("decomp_aamne_",name_sctr_aggregates,"_[0-9]{4}_wwz.rds"))
  decomp_aamne_name_sctr_aggregates_wwz_list=lapply(decomp_aamne_name_sctr_aggregates_wwz_data2load,readRDS)

  # reset initial setup
  setwd(file.path(PROJECT_DIR, PROJECT))

  # combine df rowwise
  decomp_aamne_name_sctr_aggregates_wwz<-decomp_aamne_name_sctr_aggregates_wwz_list%>%
    Reduce(f=bind_rows) %>%
    tibble::add_column(sctr_c_i=name_sctr_aggregates,.before="sctr_c_j")
  #glimpse(decomp_aamne_name_sctr_aggregates_wwz)

  saveRDS(decomp_aamne_name_sctr_aggregates_wwz %>%
    ungroup() %>% tibble::add_column(updated=Sys.Date()),
    file=file.path(pipeline, "out", paste0("decomp_aamne_",name_sctr_aggregates,"_wwz.rds")))
  # ##$##
}

print("finished: sectoral aggregates excluded as source of VA")

# ##$##
