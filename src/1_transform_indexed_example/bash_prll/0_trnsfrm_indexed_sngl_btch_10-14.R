# Introduction: we subset icio to ALL_NRR producers LOOP
# WE create datafiles with NRR-producers as BUYERS and as SELLERS of inputs
# ##@## PREAMBLE: Environment ####

#.rs.restartR()

# clear the environment
rm(list = ls())

# clear cache
gc(full=TRUE)

# clear the console
cat("\f")


# Imports: All the library imports go here

library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(conflicted)
# ##$##

# ##@## PREAMBLE: Settings - MUST CHANGE NAME
NAME <- "R_aamne_indexed"
PROJECT <- "r_aamne_wwz"
PROJECT_DIR <- "/home/mmvvff_v1"
RAW_DATA <- "0_data/"
#PROJECT_DIR <- "/Volumes/hd_mvf_datapipes/data_processing/icio_nrr/"
#RAW_DATA <- "/Volumes/hd_mvf_datasets/data_raw/quant/1_large_datasets/oecd_datasets/"

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

# ##@## vector years
boomyears_vctr<-c(as.character(2000:2013))
boomyears_range<-diff(range(c(as.numeric(boomyears_vctr))))
boomyears_max<-max(c(as.numeric(boomyears_vctr)))
boomyears_min<-min(c(as.numeric(boomyears_vctr)))
median_boomyears<-as.character(ceiling(((boomyears_max-boomyears_min)/2)+boomyears_min))
initlag_boomyears<-as.character(boomyears_min-1)

# ##$##

# ##@## CODES | VECTORS: codes and vectors for sectors

# ##@## DATA: sector codes

#codes_sector_aamne_all <- readr::read_csv(file.path( "0_data",
#  "codes_sector_oecd_aamneV18_classification.csv"))
#glimpse(codes_sector_aamne_all)

codes_sector_aamne_all <- readr::read_csv(file.path( "0_data",
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

codes_sector_aamne_all_nrrprd_upstrm <- dplyr::filter(codes_sector_aamne_all,
  nrr_upstrm_prdcrs==1)
codes_nrrprd_upstrm <- paste(codes_sector_aamne_all_nrrprd_upstrm$sector_code)

codes_sector_aamne_all_nrrprd_dwnstrm <- dplyr::filter(codes_sector_aamne_all,
  nrr_dwnstrm_prdcrs==1)
codes_nrrprd_dwnstrm <- paste(codes_sector_aamne_all_nrrprd_dwnstrm$sector_code)

# suppliers
codes_sector_aamne_all_tradables_mx <- dplyr::filter(codes_sector_aamne_all,
  tradables_mx == 1)
codes_tradables_mx <- paste(codes_sector_aamne_all_tradables_mx$sector_code)

codes_sector_aamne_all_tradables_sx <- dplyr::filter(codes_sector_aamne_all,
  tradables_sx == 1)
codes_tradables_sx <- paste(codes_sector_aamne_all_tradables_sx$sector_code)

codes_tradables_umxsx <- setdiff(union(codes_tradables_mx,codes_tradables_sx), codes_nrrprd_vc)

# manfucaturing users of end-products
codes_sector_aamne_all_mnfctrng_usrs <- dplyr::filter(codes_sector_aamne_all,
  mnfctrng_users==1)
codes_mnfctrng_usrs <- paste(codes_sector_aamne_all_mnfctrng_usrs$sector_code)


# manufacturing producers
codes_sector_aamne_all_mnfctrng_all <- dplyr::filter(codes_sector_aamne_all,
  mnfctrng_prdcrs == 1)
codes_mnfctrng_gvc <- paste(codes_sector_aamne_all_mnfctrng_all$sector_code)

codes_sector_aamne_all_mnfctrng_apprl <- dplyr::filter(codes_sector_aamne_all,
  apparel_prdcrs == 1)
codes_mnfctrng_apprl <- paste(codes_sector_aamne_all_mnfctrng_apprl$sector_code)

codes_sector_aamne_all_mnfctrng_atmtv <- dplyr::filter(codes_sector_aamne_all,
  autmtv_prdcrs == 1)
codes_mnfctrng_atmtv <- paste(codes_sector_aamne_all_mnfctrng_atmtv$sector_code)

codes_sector_aamne_all_mnfctrng_elctrncs <- dplyr::filter(codes_sector_aamne_all,
  elctrncs_prdcrs == 1)
codes_mnfctrng_elctrncs <- paste(codes_sector_aamne_all_mnfctrng_elctrncs$sector_code)

# tech intensity
codes_sector_aamne_all_techrnd_highmed <- dplyr::filter(codes_sector_aamne_all,
  techrnd_highmed == 1)
codes_techrnd_highmed <- paste(codes_sector_aamne_all_techrnd_highmed $sector_code)

codes_tradables_techrnd<-intersect(codes_techrnd_highmed,codes_tradables_umxsx)
# ##$##

# ##$##

# path_data_aamne <- "oecd_aamne/aamne18/"
path_data_aamne <- "oecd_aamne/aamne23/"

# ##@## OECD LABELS for VECTORS OF MATRICES
# ##@## aamne18
vctr_aamne18_io_fnldmnd <- c("HFCE","NPISH","GGFC","GFCF","INVNT","P33")
vctr_aamne18_io_govatax <- c("GVA","TAX","GO")
# ##$##
# ##@## aamne23
vctr_aamne23_io_fnldmnd <- c("HFCE","NONRES","NPISH","GGFC","GFCF","INVNT")
vctr_aamne23_io_govatax <- c("GVA","TAXSUB","GO")
# ##$##
vctr_aamne_io_fnldmnd <- union(vctr_aamne18_io_fnldmnd, vctr_aamne23_io_fnldmnd)
vctr_aamne_io_govatax <- union(vctr_aamne18_io_govatax, vctr_aamne23_io_govatax)
# ##$##

###### INITIATE LOOP
vctr_allyears<-as.character(c(2010:2014))
for(i in vctr_allyears){ # START of loop
Sys.sleep(0.5)
print(i)
cat("\n")

#i<-c("2010")

# ##@## Load data: AAMNE

# ICIO

aamne_io_i <- list.files(
  path = paste0(RAW_DATA, path_data_aamne),
  pattern = paste0("^.*", i, "\\.csv$"),
  full.names = TRUE)
#
if (length(aamne_io_i) == 0) {
    print(paste("Data unavailable for year",i))
    next
  }

aamne_io_i_tbl<-readr::read_csv(aamne_io_i)

# ##@## confirm AAMNE version

##### Expected dimensions of each version

dim_aamne18 <- c(4083, 4443)
dim_aamne23 <- c(6317, 6777)

if (all(dim(aamne_io_i_tbl) == dim_aamne18)) {
  aamne_io_i_tbl <- aamne_io_i_tbl %>%
    rename(cntry=cou,ownrshp=own,sctr=ind)
} else if (all(dim(aamne_io_i_tbl) == dim_aamne23)) {
  aamne_io_i_tbl <- aamne_io_i_tbl %>%
    rename(cntry_own_sctr="...1") %>%
    tidyr::separate(
      cntry_own_sctr,
      into = c("cntry","ownrshp","sctr"),
      sep = "_")
} else
{print("not ICIO-AAMNE")}

# ##$##

# ##$##

# ##@## Recode data

# We Rename columns names of Final Demand to fit 3 pieces
aamne_io_i_tbl<-aamne_io_i_tbl%>%
  rename_with(
    ~gsub("_", "_fnldmnd_", .x, fixed=TRUE),
    .cols=contains(paste(vctr_aamne_io_fnldmnd)))
aamne_io_i_tbl
# ##$##
rev(names(aamne_io_i_tbl))[1:6]

# ##@## intermediate matrix: z

# ##@## prepare
aamne_z_i <- aamne_io_i_tbl %>%
  dplyr::select(!contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(!sctr %in% vctr_aamne_io_govatax) %>% # remove aggregates
  dplyr::filter(!cntry %in% vctr_aamne_io_govatax) %>% # remove aggregates
  # the above two are equivalent to drop_na(), but preferred for readability
  # tidyr::drop_na() %>%
  # combine ownership and industry into single industry
  dplyr::mutate(own_sctr = stringr::str_c(ownrshp,sctr,sep = "_")) %>%
  dplyr::select(!c(ownrshp,sctr)) %>%
  dplyr::relocate(cntry,own_sctr) %>%
  dplyr::arrange(cntry,own_sctr) %>% # sort rows to match order in columns
  dplyr::select(cntry,own_sctr,sort(names(.))) # sort columns to match order in rows

# inspect visually order of country-own-industry in rows vs. columns
aamne_z_i
aamne_z_i[,(ncol(aamne_z_i)-6-1):ncol(aamne_z_i)]
# ##$##

# ##@## test: vector of countries and industries
# countries
countries_z_source <- unique(aamne_z_i$cntry)
countries_z_dest <- unique(
  stringr::str_extract(
    names(aamne_z_i[,!names(aamne_z_i) %in% c("cntry","own_sctr")]),
    "[A-Z]{3}")
  )

stopifnot(exprs = {all.equal(countries_z_source, countries_z_dest)})
countries_z <- intersect(countries_z_source, countries_z_dest)

# industries
industries_z_source <- unique(aamne_z_i$own_sctr)
industries_z_dest <- unique(
  stringr::str_match(
    names(aamne_z_i[,!names(aamne_z_i) %in% c("cntry","own_sctr")]),
    "[A-Z]{3}_([A-Z]{1}_[0-9A-Z]+)")[,2]
  )
#
stopifnot(exprs = {all.equal(industries_z_source, industries_z_dest)})
industries_z <- intersect(industries_z_source, industries_z_dest)
# ##$##

# ##@## output: aamne_z_i_matrix

aamne_z_i_matrix <- aamne_z_i %>%
  dplyr::select(!c(cntry,own_sctr)) %>%
  as.matrix(.) %>% unname(.)

# ##$##

# ##@##  output: aamne_z_i_indxd
aamne_z_i_indxd <- aamne_z_i %>%
  tidyr::separate(own_sctr, c("ownrshp","sctr")) %>%
  tidyr::gather(k, "int_z", -(c(cntry,ownrshp,sctr))) %>%
  tidyr::separate(k, c("cntry_c","ownrshp_c_j","sctr_c_j")) %>% #buyers
  dplyr::rename(cntry_s=cntry,ownrshp_s_i=ownrshp,sctr_s_i=sctr) %>% #sellers
  dplyr::mutate(across(where(is.character),as.factor))

# ##$##

# ##$##

# ##@## final demand matrix: f

# ##@## prepare
aamne_f_i <- aamne_io_i_tbl %>%
  dplyr::select(cntry,ownrshp,sctr,contains("fnldmnd")) %>% # include final demand components
  dplyr::filter(!sctr %in% vctr_aamne_io_govatax) %>% # remove aggregates
  dplyr::filter(!cntry %in% vctr_aamne_io_govatax) %>% # remove aggregates
  # although the above two are equivalent to drop_na(), they more readable
  # tidyr::drop_na() %>%
  # combine ownership and industry into single industry
  dplyr::mutate(own_sctr = stringr::str_c(ownrshp,sctr,sep = "_")) %>%
  dplyr::select(!c(ownrshp,sctr)) %>%
  dplyr::relocate(cntry,own_sctr) %>%
  dplyr::arrange(cntry,own_sctr) %>% # sort rows to match order in columns
  dplyr::select(cntry,own_sctr,sort(names(.))) # sort columns to match order in rows

# inspect visually order of country-own-industry in rows vs. columns
aamne_f_i
aamne_f_i[,(ncol(aamne_f_i)-2-1):ncol(aamne_f_i)]
# ##$##

# ##@## vector of countries and industries
# producers: input buyers and source of FD
countries_f_source <- unique(aamne_f_i$cntry)
# consumers: destination of FD
countries_f_dest <- unique(
  stringr::str_extract(
    names(aamne_f_i[,!names(aamne_f_i) %in% c("cntry","own_sctr")]),
    "[A-Z]{3}")
  )
# test
stopifnot(exprs = {all.equal(countries_f_source, countries_f_dest)})
# output
countries_f <- intersect(countries_f_source, countries_f_dest)

# producers: input buyers and source of FD
industries_f <- unique(aamne_f_i$own_sctr)

# consumers: destination of FD
components_f <- unique(
  stringr::str_match(
    names(aamne_f_i[,!names(aamne_f_i) %in% c("cntry","own_sctr")]),
    "[a-z]+_([0-9A-Z]+)")[,2]
  )
# test
if (length(industries_f) == 68) {
  stopifnot(exprs = {all.equal(components_f, sort(vctr_aamne18_io_fnldmnd))})
} else if (length(industries_f) == 82) {
  stopifnot(exprs = {all.equal(components_f, sort(vctr_aamne23_io_fnldmnd))})
} else {print("Not ICIO-AAMNE")}
# ##$##

# ##@## matrix: aamne_f_i_matrix
aamne_f_i_matrix <- aamne_f_i %>%
  dplyr::select(!c(cntry,own_sctr)) %>%
  as.matrix(.) %>% unname(.)
dim(aamne_f_i_matrix)
# ##$##

# ##@## indexed: aamne_fnldmnd_i_indxd

aamne_fnldmnd_i_indxd <- aamne_f_i %>%
  tidyr::separate(own_sctr, c("ownrshp","sctr")) %>%
  tidyr::gather(k, "value", -(c(cntry,ownrshp,sctr))) %>%
  tidyr::separate(k, c("cntry_c","matrix","matrix_compnnt")) %>% #buyers
  dplyr::rename(cntry_s=cntry,ownrshp_s_i=ownrshp,sctr_s_i=sctr) %>% #sellers
  dplyr::mutate(across(where(is.character),as.factor)) #sellers
# ##$##

# ##$##

# ##@## gross output vector: go

# ##@## prepare
if (all(dim(aamne_io_i_tbl)[1] == dim_aamne18[1])) {
  aamne_go_i <- aamne_io_i_tbl %>%
    dplyr::filter(sctr %in% c("GO")) %>% # focus on go
    dplyr::select(!c(cntry,ownrshp)) %>%
    dplyr::select(sctr,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_go_i <- aamne_io_i_tbl %>%
    dplyr::filter(cntry %in% c("GO")) %>% # focus on go
    dplyr::select(!c(sctr,ownrshp)) %>%
    dplyr::select(cntry,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else
{print("not ICIO-AAMNE")}

# inspect visually order of country-own-industry in rows vs. columns
aamne_go_i
aamne_go_i[,(ncol(aamne_go_i)-2-1):ncol(aamne_go_i)]
# ##$##

# ##@## vector of countries and industries

# countries:
# producers: input buyers and source of FD
countries_go <- unique(
  stringr::str_extract(
    names(aamne_go_i[,!names(aamne_go_i) %in% c("sctr")]),
    "[A-Z]{3}")
  )
#
industries_go <- unique(
  stringr::str_match(
    names(aamne_go_i[,!names(aamne_go_i) %in% c("sctr")]),
    "[A-Z]{3}_([A-Z]{1}_[0-9A-Z]+)")[,2]
  )

# ##$##

# ##@## matrix: aamne_go_i_vector
aamne_go_i_vector <- aamne_go_i %>%
  dplyr::select(!where(is.character)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##


# ##$##

# ##@## gross output vector: va

# ##@## prepare
if (all(dim(aamne_io_i_tbl)[1] == dim_aamne18[1])) {
  aamne_va_i <- aamne_io_i_tbl %>%
    dplyr::select(sctr,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(sctr %in% c("GVA")) %>% # focus on go
    dplyr::select(!c(cntry,ownrshp)) %>%
    dplyr::select(sctr,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_va_i <- aamne_io_i_tbl %>%
    dplyr::select(cntry,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(cntry %in% c("GVA")) %>% # focus on go
    dplyr::select(!c(sctr,ownrshp)) %>%
    dplyr::select(cntry,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else
{print("not ICIO-AAMNE")}

# inspect visually order of country-own-industry in rows vs. columns
aamne_va_i
aamne_va_i[,(ncol(aamne_va_i)-2-1):ncol(aamne_va_i)]
# ##$##

# ##@## vector of countries and industries

# countries:
# producers: input buyers and source of output
countries_va <- unique(
  stringr::str_extract(
    names(aamne_va_i[,!names(aamne_va_i) %in% c("sctr")]),
    "[A-Z]{3}")
  )
#
industries_va <- unique(
  stringr::str_match(
    names(aamne_va_i[,!names(aamne_va_i) %in% c("sctr")]),
    "[A-Z]{3}_([A-Z]{1}_[0-9A-Z]+)")[,2]
  )

# ##$##

# ##@## matrix: aamne_va_i_vector
aamne_va_i_vector <- aamne_va_i %>%
  dplyr::select(!where(is.character)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##

# ##$##

# ##@## gross output vector: gva

# ##@## prepare
if (all(dim(aamne_io_i_tbl)[1] == dim_aamne18[1])) {
  aamne_gva_i <- aamne_io_i_tbl %>%
    dplyr::select(sctr,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(sctr %in% c("GVA","TAX")) %>% # focus on VA
    dplyr::select(!c(cntry,ownrshp,sctr)) %>%
    dplyr::summarize(across(.cols = where(is.numeric),.fns = sum)) %>%
    tibble::add_column(sctr=c("GVA"), .before = 1) %>%
    dplyr::select(sctr,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_gva_i <- aamne_io_i_tbl %>%
    dplyr::select(cntry,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(cntry %in% c("GVA","TAXSUB")) %>% # focus on VA
    dplyr::select(!c(cntry,ownrshp,sctr)) %>%
    dplyr::summarize(across(.cols = where(is.numeric),.fns = sum)) %>%
    tibble::add_column(sctr=c("GVA"), .before = 1) %>%
    dplyr::select(sctr,sort(names(.))) %>% # sort columns
    dplyr::rename_with(~ "matrix_compnnt",
    .cols = where(is.character))
} else
{print("not ICIO-AAMNE")}

any(is.na(aamne_gva_i))
aamne_gva_i
# inspect visually order of country-own-industry in rows vs. columns
aamne_gva_i
aamne_gva_i[,(ncol(aamne_gva_i)-2-1):ncol(aamne_gva_i)]
# ##$##

# ##@## vector of countries and industries

# countries:
# producers: input buyers and source of output
countries_gva <- unique(
  stringr::str_extract(
    names(aamne_gva_i[,!names(aamne_gva_i) %in% c("sctr")]),
    "[A-Z]{3}")
  )
#
industries_gva <- unique(
  stringr::str_match(
    names(aamne_gva_i[,!names(aamne_gva_i) %in% c("sctr")]),
    "[A-Z]{3}_([A-Z]{1}_[0-9A-Z]+)")[,2]
  )

# ##$##

# ##@## matrix: aamne_gva_i_vector
aamne_gva_i_vector <- aamne_gva_i %>%
  dplyr::select(!where(is.character)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##

# ##$##

# ##@## TEST decompr requirements: order and size of countries and industries

# size of countries and industries
stopifnot(exprs = {
  all.equal(
    countries_z,
    countries_f,
    countries_go,
    countries_va,
    countries_gva
  )
  all.equal(
    industries_z,
    industries_f,
    industries_go,
    industries_va,
    industries_gva
  )
})

countries_aamne <-Reduce(
  intersect,
  list(countries_z,
    countries_f,
    countries_go,
    countries_va,
    countries_gva)
  )

industries_aamne <- Reduce(
  intersect,
  list(industries_z,
    industries_f,
    industries_go,
    industries_va,
    industries_gva)
  )
# ##$##

# ##@## TEST decompr requirements: size of matrices and vectors
stopifnot(exprs = {
  all.equal(
    dim(aamne_z_i_matrix)[1],
    dim(aamne_f_i_matrix)[1],
    length(aamne_go_i_vector),
    length(aamne_va_i_vector),
    length(aamne_gva_i_vector)
  )
  all.equal(
    dim(aamne_z_i_matrix)[2],
    length(aamne_go_i_vector),
    length(aamne_va_i_vector),
    length(aamne_gva_i_vector)
  )
})

if (all(dim(aamne_io_i_tbl)[1] == dim_aamne18[1])) {
  stopifnot(exprs = {
    all.equal(
      dim(aamne_f_i_matrix)[2],
      length(countries_aamne)*length(vctr_aamne18_io_fnldmnd)
    )
  })
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  stopifnot(exprs = {
    all.equal(
      dim(aamne_f_i_matrix)[2],
      length(countries_aamne)*length(vctr_aamne23_io_fnldmnd)
    )
  })
}
# ##$##

# ##@## Save

# ##@## aamne_z_i_indxd
stopifnot(exprs = {
  any(sapply(aamne_z_i_indxd, function(x)any(is.na(x))) %in% "FALSE") # TRUE so all cols do not have NA (FALSE)
  })

saveRDS(aamne_z_i_indxd,
  file=paste0(file.path(pipeline, "out",""),"aamne_z_",i,"_indxd.rds"))
# ##$##

# ##@## aamne_fnldmnd_i_indxd
stopifnot(exprs = {
  any(sapply(aamne_fnldmnd_i_indxd, function(x)any(is.na(x))) %in% "FALSE") # TRUE so all cols do not have NA (FALSE)
  })
saveRDS(aamne_fnldmnd_i_indxd,
  file=paste0(file.path(pipeline, "out",""),"aamne_fnldmnd_",i,"_indxd.rds"))
# ##$##

# ##@## aamne_prdctn_i_indxd
aamne_prdctn_i_indxd <- dplyr::bind_rows(
  aamne_go_i,
  aamne_va_i %>% dplyr::mutate(matrix_compnnt=ifelse(
    matrix_compnnt %in% "GVA", "VA", matrix_compnnt)),
  aamne_gva_i) %>%
  dplyr::mutate(across(where(is.character),as.factor))

stopifnot(exprs = {
  any(sapply(aamne_prdctn_i_indxd, function(x)any(is.na(x))) %in% "FALSE") # TRUE so all cols do not have NA (FALSE)
  })
#
saveRDS(aamne_prdctn_i_indxd,
  file=paste0(file.path(pipeline, "out",""),"aamne_prdctn_",i,"_indxd.rds"))


# ##$##

# ##$##

} # END of loop

warnings()
