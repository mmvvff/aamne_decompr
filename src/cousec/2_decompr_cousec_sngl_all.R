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

###### INITIATE LOOP
vctr_allyears<-as.character(c(2000:2003))
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

#### Unit of analysis: COUNTRY-SECTOR
#### estimates where the source of VA is a subset of sectors;
#### useful for analysis concerned with specific sector-sector relations

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

# ##@## for selected sectoral aggregates: include as sources of VA

for (idx in seq(nrow(vctr_sctr_aggregates))) {

  codes_sctr_aggregates <- vctr_sctr_aggregates[idx,]$"codes"[[1]]

  # names for included sectors
  name_sctr_aggregates <- vctr_sctr_aggregates[idx,]$"names"[[1]]

  # ##@## set to zeros all sectors not part of sctr_aggregates
  decomp_aamne_sctr_aggregates_i <- decomp_aamne_i

  Vc_sctr_aggregates_tibble <- tibble::enframe(
    decomp_aamne_sctr_aggregates_i$Vc,
    name = "name", value = "value") %>%
    dplyr::mutate(value=if_else(
      stringr::str_detect(name,
        pattern = paste0("(",codes_sctr_aggregates,")$", collapse = "|"),
        negate=TRUE), # include
      0,value))
  Vc_sctr_aggregates <- tibble::deframe(Vc_sctr_aggregates_tibble)
  decomp_aamne_sctr_aggregates_i$Vc <- Vc_sctr_aggregates
  # ##$##

  decomp_aamne_sctr_aggregates_i_wwz <- tibble::tibble(
    decompr::wwz(decomp_aamne_sctr_aggregates_i, verbose = TRUE)) %>%
    tibble::add_column(year=factor(i)) %>%
    dplyr::relocate(year,.after=3) %>%
    dplyr::rename(
      cntry_c=Exporting_Country,
      sctr_c_j=Exporting_Industry,
      cntry_p=Importing_Country)

  saveRDS(decomp_aamne_sctr_aggregates_i_wwz,
    file=paste0(
      file.path(pipeline, "store",""),
      "decomp_aamne_",name_sctr_aggregates,"_",i,"_wwz.rds"))
}

# ##$##

# ##@## for selected sectoral aggregates: exclude as sources of VA

for (idx in seq(nrow(vctr_sctr_aggregates))) {

  codes_sctr_aggregates <- vctr_sctr_aggregates[idx,]$"codes"[[1]]

  # names for excluded
  name_sctr_aggregates <- func_xstring(vctr_sctr_aggregates[idx,]$"names"[[1]])

  # ##@## set to zeros all sectors part of sctr_aggregates
  decomp_aamne_sctr_aggregates_i <- decomp_aamne_i

  Vc_sctr_aggregates_tibble <- tibble::enframe(
    decomp_aamne_sctr_aggregates_i$Vc,
    name = "name", value = "value") %>%
    dplyr::mutate(value=if_else(
      stringr::str_detect(name,
        pattern = paste0("(",codes_sctr_aggregates,")$", collapse = "|")), # exclude
      0,value))
  Vc_sctr_aggregates <- tibble::deframe(Vc_sctr_aggregates_tibble)
  decomp_aamne_sctr_aggregates_i$Vc <- Vc_sctr_aggregates
  # ##$##

  decomp_aamne_sctr_aggregates_i_wwz <- tibble::tibble(
    decompr::wwz(decomp_aamne_sctr_aggregates_i, verbose = TRUE)) %>%
    tibble::add_column(year=factor(i)) %>%
    dplyr::relocate(year,.after=3) %>%
    dplyr::rename(
      cntry_c=Exporting_Country,
      sctr_c_j=Exporting_Industry,
      cntry_p=Importing_Country)

  saveRDS(decomp_aamne_sctr_aggregates_i_wwz,
    file=paste0(
      file.path(pipeline, "store",""),
      "decomp_aamne_",name_sctr_aggregates,"_",i,"_wwz.rds"))
}

# ##$##

# ##$##

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
    tibble::add_column(sctr_s_i=name_sctr_aggregates,.before="sctr_c_j")
  #glimpse(decomp_aamne_name_sctr_aggregates_wwz)

  saveRDS(decomp_aamne_name_sctr_aggregates_wwz%>%
    ungroup() %>% tibble::add_column(updated=Sys.Date()),
    file=file.path(pipeline, "out", paste0("decomp_aamne_",name_sctr_aggregates,"_wwz.rds")))
  # ##$##
}

# ##$##

# ##@## collect estimates for sectoral aggregates excluded as source of VA

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
    tibble::add_column(sctr_s_i=name_sctr_aggregates,.before="sctr_c_j")
  #glimpse(decomp_aamne_name_sctr_aggregates_wwz)

  saveRDS(decomp_aamne_name_sctr_aggregates_wwz%>%
    ungroup() %>% tibble::add_column(updated=Sys.Date()),
    file=file.path(pipeline, "out", paste0("decomp_aamne_",name_sctr_aggregates,"_wwz.rds")))
  # ##$##
}

# ##$##
