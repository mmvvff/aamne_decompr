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
library(decompr)
library(foreach)
library(doParallel)
library(conflicted)
# ##$##

# ##@## PREAMBLE: 2 Settings ####
NAME <- "R_aamne_decompr"
PROJECT <- "r_aamne_nrr"
PROJECT_DIR <- "/Volumes/hd_mvf_datapipes/data_processing/icio_nrr/"
EXTERNAL_HD <- "/Volumes/hd_mvf_datasets/data_raw/quant/1_large_datasets/oecd_datasets/"


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

# ##@## CODES | VECTORS: Load country codes

# ##@## wb income and oecd membership
codes_oecd_membership <- read_csv(file.path("empirical", "0_data", "external", "codes_cntrs_oecd_members_all.csv"))
class(codes_oecd_membership)
codes_oecd_membership <- codes_oecd_membership %>%
  rename(country_code_iso3=country_isoalpha3_code)%>%
  pivot_longer(-country_code_iso3,names_to="year",values_to="yrthrshld_oecdmbrshp")%>%
  mutate(year=as_factor(year))
codes_oecd_membership

wb_income_classifications <- read_csv(file.path("empirical", "0_data", "external", "codes_cntrs_wb_incmgrps_1987_2015.csv"))
class(wb_income_classifications)
wb_income_classifications <- wb_income_classifications %>%
pivot_longer(-country_code_iso3, names_to = "year", values_to = "yrthrshld_incmgrp")
wb_income_classifications

codes_cntrs_dvlpment<-left_join(
  wb_income_classifications,
  codes_oecd_membership) %>%
  mutate(yrthrshld_oecdmbrshp=if_else(is.na(yrthrshld_oecdmbrshp),c("NON-OECD"),yrthrshld_oecdmbrshp)) %>%
  group_by(year) %>%
  mutate(yrthrshld_dvlpmnt6=case_when(
    yrthrshld_incmgrp==c("HIC") & yrthrshld_oecdmbrshp==c("OECD") ~ "OECD_HIC",
    yrthrshld_incmgrp==c("HIC") & yrthrshld_oecdmbrshp==c("NON-OECD") ~ "NON-OECD_HIC",
    c(yrthrshld_incmgrp==c("UMIC") | yrthrshld_incmgrp==c("LMIC")) & yrthrshld_oecdmbrshp==c("OECD") ~ "OECD_MIC",
    c(yrthrshld_incmgrp==c("UMIC") | yrthrshld_incmgrp==c("LMIC")) & yrthrshld_oecdmbrshp==c("NON-OECD") ~ "NON-OECD_MIC",
    yrthrshld_incmgrp==c("LIC") & yrthrshld_oecdmbrshp==c("OECD") ~ "OECD_LIC",
    yrthrshld_incmgrp==c("LIC") & yrthrshld_oecdmbrshp==c("NON-OECD") ~ "NON-OECD_LIC")) %>%
  mutate(yrthrshld_dvlpmnt2=if_else(
    yrthrshld_incmgrp==c("HIC") & yrthrshld_oecdmbrshp==c("OECD"),"Highly Industrialized","Emerging"))

#
# yrthrshld_dvlpmnt2
codes_cntrs_dvlpment$yrthrshld_dvlpmnt2<-factor(
  codes_cntrs_dvlpment$yrthrshld_dvlpmnt2,
  levels=c("Highly Industrialized","Emerging"))

#glimpse(codes_cntrs_dvlpment) # output
# ##$##

codes_cntrs_dvlpment_initial_hghind<-codes_cntrs_dvlpment%>%
  dplyr::filter(year %in% c("2004")) %>%
  dplyr::filter(yrthrshld_dvlpmnt2 %in% c("Highly Industrialized"))
codes_cntrs_hghind_vctr<-c(codes_cntrs_dvlpment_initial_hghind$country_code_iso3)

# UNSD
# we load our csv file to create vectors of development-level and regions
unsd_country_codes <- read_csv(file.path("empirical", "0_data", "external", "codes_cntrs_unsd_mvf.csv"))

# ICIO codes_cntrs
# codes_cntrs_icioV18_all
codes_cntrs_icioV18_all <- read_csv(file.path("empirical", "0_data", "external",
  "codes_cntrs_oecd_icioV18_all.csv"))

codes_cntrs_icioV18_all_vctr <- c(codes_cntrs_icioV18_all$country_code_iso3) #facilitates filtering/selecting
# icio row and wld
codes_cntrs_icio_wld <- c("WLD")
codes_cntrs_icio_row <- c("ROW")

# CN | MX
codes_cntrs_icio_mx_cn <- read_csv(file.path("empirical", "0_data", "external",
  "codes_cntrs_icio_mx_cn.csv"))

# ##$##
# ##@## CODES | VECTORS: codes and vectors for sectors

# ##@## DATA: sector codes

# we load our csv file to use for the creation of vectors defining sector_codes for nrrprd_vc
codes_sector_icioV18 <- read.csv(file.path("empirical", "0_data", "external",
  "codes_sector_oecdV18_classification.csv"))
codes_sector_icioV18 <- codes_sector_icioV18 %>%
  mutate_if(sapply(codes_sector_icioV18, is.numeric), as.factor)
#glimpse(codes_sector_icioV18)

# we load our csv file to use for filtering non-sector_codes in datafiles
codes_sector_icioV18all <- read_csv(file.path("empirical", "0_data", "external",
  "codes_sector_oecdV18_all.csv"))
codes_sector_icioV18all$sector_code <- str_sub(codes_sector_icioV18all$sector_code, 2)
codes_sector_icioV18all_vctr <- as_vector(codes_sector_icioV18all$sector_code)
#glimpse(codes_sector_icioV18all_vctr)

codes_sector_aamne_all <- read_csv(file.path("empirical", "0_data", "external",
  "codes_sector_oecd_aamneV18_classification.csv"))
#glimpse(codes_sector_aamne_all)

# ##$##

# ##@## VECTORS: sector_codes according to sectors and segments ####
# we create a vector of sectors that distinguish between NRR-based sectors and
# manufacturing sectors we use the sector codes of icio (Eurostat based on ISIC
# Rev. 4)
# we create a vector of codes of nrr vc, sectors and segments

# suppliers
codes_sector_aamne_all_tradables_mx <- dplyr::filter(codes_sector_aamne_all,
  tradables_mx == 1)
codes_tradables_mx <- paste(codes_sector_aamne_all_tradables_mx$sector_code)
unique(codes_tradables_mx)

codes_sector_aamne_all_tradables_sx <- dplyr::filter(codes_sector_aamne_all,
  tradables_sx == 1)
codes_tradables_sx <- paste(codes_sector_aamne_all_tradables_sx$sector_code)
unique(codes_tradables_sx)

codes_tradables_umxsx <- union(codes_tradables_mx,codes_tradables_sx)
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
# ##@## CODES | VECTORS: UNIVERSE OF STUDY: global
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

#setup parallel backend to use many processors
cores = detectCores()
# substract n processors to avoid overloading
cl <- makeCluster(cores[1]-2)
registerDoParallel(cl)

###### INITIATE LOOP
vctr_allyears<-as.character(as.vector(2005:2013))

foreach(
  i=vctr_allyears,
  .packages=c("readr","tidyr","dplyr")) %dopar% { # START of loop

#i<-c("2010")

# ##@## Load data
countries_aamne <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_countries_",i,".rds"))
#
industries_aamne <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_industries_",i,".rds"))
#
aamne_z_i_matrix <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_z_",i,"_matrix.rds"))
#
aamne_f_i_matrix <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_f_",i,"_matrix.rds"))
#
aamne_go_i_vector <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_go_",i,"_vector.rds"))
#
aamne_va_i_vector <- readRDS(paste0(file.path("empirical",
  "2_pipeline","R_aamne_decompr","tmp",""),
  "data_aamne_va_",i,"_vector.rds"))
#
aamne_gva_i_vector <- readRDS(paste0(file.path("empirical",
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

#### Unit of analysis: COUNTRY
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
