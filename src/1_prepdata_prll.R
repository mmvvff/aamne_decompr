# Introduction: Prepare AAMNE v18 data for decompr
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

# library(miceadds)
library(readr)
library(tidyr)
library(dplyr)
library(foreach)
library(doParallel)
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

#setup parallel backend to use many processors
cores = detectCores()
# substract n processors to avoid overloading
cl <- makeCluster(cores[1]-1)
registerDoParallel(cl)

###### INITIATE LOOP
vctr_allyears<-as.character(c(2000:2013))

foreach(
  i=vctr_allyears,
  .packages=c("readr","tidyr","dplyr")) %dopar% { # START of loop

#i<-c("2010")

# ##@## Load data: AAMNE

# ICIO
# we load Rdata icio

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

# confirm order of country-own-industry in rows vs. columns
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

# confirm order of country-own-industry in rows vs. columns
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

# ##$##

# ##@## gross output vector: go

# ##@## prepare
if (all(dim(aamne_io_i_tbl)[1] == dim_aamne18[1])) {
  aamne_go_i <- aamne_io_i_tbl %>%
    dplyr::filter(sctr %in% c("GO")) %>% # focus on go
    dplyr::select(!c(cntry,ownrshp)) %>%
    dplyr::select(sctr,sort(names(.))) # sort columns
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_go_i <- aamne_io_i_tbl %>%
    dplyr::filter(cntry %in% c("GO")) %>% # focus on go
    dplyr::select(!c(sctr,ownrshp)) %>%
    dplyr::select(cntry,sort(names(.))) # sort columns
} else
{print("not ICIO-AAMNE")}

# confirm order of country-own-industry in rows vs. columns
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
    dplyr::select(sctr,sort(names(.))) # sort columns
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_va_i <- aamne_io_i_tbl %>%
    dplyr::select(cntry,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(cntry %in% c("GVA")) %>% # focus on go
    dplyr::select(!c(sctr,ownrshp)) %>%
    dplyr::select(cntry,sort(names(.))) # sort columns
} else
{print("not ICIO-AAMNE")}

# confirm order of country-own-industry in rows vs. columns
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
    dplyr::select(sctr,sort(names(.))) # sort columns to match order in rows
} else if (all(dim(aamne_io_i_tbl)[1] == dim_aamne23[1])) {
  aamne_gva_i <- aamne_io_i_tbl %>%
    dplyr::select(cntry,!contains("fnldmnd")) %>% # remove final demand components
    dplyr::filter(cntry %in% c("GVA","TAXSUB")) %>% # focus on VA
    dplyr::select(!c(cntry,ownrshp,sctr)) %>%
    dplyr::summarize(across(.cols = where(is.numeric),.fns = sum)) %>%
    tibble::add_column(sctr=c("GVA"), .before = 1) %>%
    dplyr::select(sctr,sort(names(.))) # sort columns to match order in rows
} else
{print("not ICIO-AAMNE")}

any(is.na(aamne_gva_i))
aamne_gva_i
# confirm order of country-own-industry in rows vs. columns
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
# countries_aamne
saveRDS(countries_aamne,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_countries_",i,".rds"))
#
# industries_aamne
saveRDS(industries_aamne,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_industries_",i,".rds"))

# aamne_z_i_matrix
saveRDS(aamne_z_i_matrix,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_z_",i,"_matrix.rds"))

# aamne_f_i_matrix
saveRDS(aamne_f_i_matrix,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_f_",i,"_matrix.rds"))

# aamne_go_i_vector
saveRDS(aamne_go_i_vector,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_go_",i,"_vector.rds"))

# aamne_va_i_vector
saveRDS(aamne_va_i_vector,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_va_",i,"_vector.rds"))

# aamne_gva_i_vector
saveRDS(aamne_gva_i_vector,
  file=paste0(
    file.path(pipeline, "tmp",""),
    "data_aamne_gva_",i,"_vector.rds"))

# ##$##

}

#stop cluster
stopCluster(cl)
