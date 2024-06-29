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

#library(miceadds)
library(tidyverse)
library(progress)
library(decompr)
library(conflicted)
# ##$##

# ##@## PREAMBLE: 2 Settings ####
NAME <- "R_aamne18_01_preparedata"
PROJECT <- "aamne_decompr"
#PROJECT_DIR <- "/Users/manuel/datapipes_mirror/icio_nrr/"
PROJECT_DIR <- "/Users/manuel/gdrive/prgrmmng/git_repos/"
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

path_data_aamne <- "oecd_aamne/aamne18"

###### INITIATE LOOP
vctr_allyears<-as.character(as.vector(2005:2016))
pb<-progress_bar$new(total=length(vctr_allyears))
pb$tick(0)
for(i in vctr_allyears){ # START of loop
Sys.sleep(1)
cat("\n")
print(i)
pb$tick()
cat("\n")
flush.console()

#i<-c("2015")

# ##@## Load data: AAMNE

# ICIO
# we load Rdata icio
setwd(file.path(EXTERNAL_HD))

aamne_io_i_tbl<-read_csv(paste0(
  file.path(path_data_aamne,"3_icio_split_ownership",""),
  "ICIOMNE",i,".csv")) %>%
  rename(cntry=cou,ownrshp=own,sctr=ind)
dim(aamne_io_i_tbl)

setwd(file.path(PROJECT_DIR, PROJECT))


# ##$##

# ##@## Recode data

# ##@## VECTORS OF MATRICES
vctr_aamne_io_fnldmnd<-c("HFCE","NPISH","GGFC","GFCF","INVNT","P33")
vctr_aamne_io_govatax<-c("GVA","TAX","GO")
# ##$##

# ##@## We Rename columns names of Final Demand to fit 3 pieces
aamne_io_i_tbl<-aamne_io_i_tbl%>%
  rename_with(
    ~gsub("_", "_fnldmnd_", .x, fixed=TRUE),
    .cols=contains(paste(vctr_aamne_io_fnldmnd)))
aamne_io_i_tbl
# ##$##

# ##$##

# ##@## intermediate matrix: z

# ##@## prepare
aamne_z_i <- aamne_io_i_tbl %>%
  dplyr::select(!contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(!sctr %in% vctr_aamne_io_govatax) %>% # remove aggregates
  # combine ownership and industry into single industry
  dplyr::mutate(own_sctr = stringr::str_c(ownrshp,sctr,sep = "_")) %>%
  dplyr::select(!c(ownrshp,sctr)) %>%
  dplyr::relocate(cntry,own_sctr) %>%
  dplyr::arrange(cntry,own_sctr) %>% # sort rows to match order in columns
  dplyr::select(cntry,own_sctr,sort(names(.))) # sort columns to match order in rows
aamne_z_i

# confirm order of country-own-industry in rows vs. columns
aamne_z_i
aamne_z_i[,(ncol(aamne_z_i)-6-1):ncol(aamne_z_i)]
# ##$##

# ##@## vector of countries and industries
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

# ##@## matrix: aamne_z_i_matrix
aamne_z_i_matrix <- aamne_z_i %>%
  dplyr::select(!c(cntry,own_sctr)) %>%
  as.matrix(.) %>% unname(.)
dim(aamne_z_i_matrix)
# ##$##

# ##$##

# ##@## final demand matrix: f

# ##@## prepare
aamne_f_i <- aamne_io_i_tbl %>%
  dplyr::select(cntry,ownrshp,sctr,contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(!sctr %in% vctr_aamne_io_govatax) %>% # remove aggregates
  # combine ownership and industry into single industry
  dplyr::mutate(own_sctr = stringr::str_c(ownrshp,sctr,sep = "_")) %>%
  dplyr::select(!c(ownrshp,sctr)) %>%
  dplyr::relocate(cntry,own_sctr) %>%
  dplyr::arrange(cntry,own_sctr) %>% # sort rows to match order in columns
  dplyr::select(cntry,own_sctr,sort(names(.))) # sort columns to match order in rows
aamne_f_i

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
stopifnot(exprs = {all.equal(components_f, sort(vctr_aamne_io_fnldmnd))})
# output
fnldmnd <- intersect(components_f,sort(vctr_aamne_io_fnldmnd))
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
aamne_go_i <- aamne_io_i_tbl %>%
  dplyr::select(sctr,!contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(sctr %in% c("GO")) %>% # focus on go
  dplyr::select(!c(cntry,ownrshp)) %>%
  dplyr::select(sctr,sort(names(.))) # sort columns
aamne_go_i

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
  dplyr::select(!c(sctr)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##

# ##$##

# ##@## gross output vector: va

# ##@## prepare
aamne_va_i <- aamne_io_i_tbl %>%
  dplyr::select(sctr,!contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(sctr %in% c("GVA")) %>% # focus on go
  dplyr::select(!c(cntry,ownrshp)) %>%
  dplyr::select(sctr,sort(names(.))) # sort columns
aamne_va_i

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
  dplyr::select(!c(sctr)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##

# ##$##

# ##@## gross output vector: gva

# ##@## prepare
aamne_gva_i <- aamne_io_i_tbl %>%
  dplyr::select(sctr,!contains("fnldmnd")) %>% # remove final demand components
  dplyr::filter(sctr %in% c("GVA","TAX")) %>% # focus on VA
  dplyr::select(!c(cntry,ownrshp,sctr)) %>%
  dplyr::summarize(across(.cols = where(is.numeric),.fns = sum)) %>%
  tibble::add_column(sctr=c("GVA"), .before = 1) %>%
  dplyr::select(sctr,sort(names(.))) # sort columns to match order in rows
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
  dplyr::select(!c(sctr)) %>%
  dplyr::slice(1) %>% as.numeric(.)
# ##$##

# ##$##

# ##@## TEST: order and size of countries and industries

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

# ##@## TEST: size of matrices and vectors
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
  all.equal(
    dim(aamne_f_i_matrix)[2],
    length(countries_aamne)*length(vctr_aamne_io_fnldmnd)
  )
})

# ##$##

# ##@## Save files

# aamne_z_i_matrix
saveRDS(aamne_z_i_matrix,
  file=paste0(
    file.path(pipeline, "store",""),
    "data_aamnev_z_",i,"_matrix.rds"))
#
# aamne_f_i_matrix
saveRDS(aamne_f_i_matrix,
  file=paste0(
    file.path(pipeline, "store",""),
    "data_aamne_f_",i,"_matrix.rds"))

# aamne_go_i_vector
saveRDS(aamne_go_i_vector,
  file=paste0(
    file.path(pipeline, "store",""),
    "data_aamne_go_",i,"_vector.rds"))
#
# aamne_va_i_vector
saveRDS(aamne_va_i_vector,
  file=paste0(
    file.path(pipeline, "store",""),
    "data_aamne_va_",i,"_vector.rds"))
#
# aamne_gva_i_vector
saveRDS(aamne_gva_i_vector,
  file=paste0(
    file.path(pipeline, "store",""),
    "data_aamne_gva_",i,"_vector.rds"))
#

# ##$##

}
