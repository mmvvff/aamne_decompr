# Introduction: Estimate VA content based on Wang et al.
# ##@## PREAMBLE: Environment ####

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
library(decompr)
library(foreach)
library(doParallel)
library(conflicted)
# ##$##

# ##@## PREAMBLE: 2 Settings ####
NAME <- "R_aamne_decompr_cou"
PROJECT <- Sys.getenv("AAMNE_PROJECT", "")
PROJECT_DIR <- Sys.getenv("AAMNE_PROJECT_DIR", ".")
RAW_DATA <- Sys.getenv("AAMNE_RAW_DATA", "0_data/")
# source of the yearly CSVs: FALSE = downloaded from the URL lists into RAW_DATA; TRUE = read in place from DATA_SOURCES
DATA_FROM_SOURCES <- as.logical(Sys.getenv("AAMNE_DATA_FROM_SOURCES", "FALSE"))
DATA_SOURCES <- Sys.getenv("AAMNE_DATA_SOURCES", "")
# destination of the pipeline folder (intermediate and final outputs); relative paths start at the project root
PIPELINE_DIR <- Sys.getenv("AAMNE_PIPELINE_DIR", "2_pipeline")


# Set working directory. Resolve the project root to an absolute path so that
# repeated setwd() calls (e.g. when scripts are chained via source()) stay
# stable regardless of the current working directory.

PROJECT_DIR <- normalizePath(file.path(PROJECT_DIR, PROJECT), mustWork = FALSE)
PROJECT <- ""
WD_ORIG <- getwd() # original working directory, restored at the end of the script
setwd(PROJECT_DIR)
message("[", NAME, "] project root: ", PROJECT_DIR)

# Set up pipeline folder if missing The code below will automatically create a
# pipeline folder for this code file if it does not exist.

pipeline <- file.path(PIPELINE_DIR, NAME)

if (!dir.exists(pipeline)) {
  dir.create(pipeline, recursive = TRUE)
  for (folder in c("out", "store", "tmp")) {
    dir.create(file.path(pipeline, folder))
  }
}
# ##$##

#setup parallel backend: one worker per 7 GB of RAM, after reserving 2 GB (at least 1)
ram_gb <- if (file.exists("/proc/meminfo")) {
  as.numeric(gsub("\\D", "", grep("MemTotal", readLines("/proc/meminfo"), value = TRUE))) / 1024^2
} else {
  as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1024^3
}
cl <- makeCluster(max(1, floor((ceiling(ram_gb) - 2) / 7)), outfile="")
registerDoParallel(cl)

# version: "aamne23", "aamne26" (aAMNE) or "icio2026" (ICIO, no ownership split); override via env var AAMNE_VERSION
aamne_version <- Sys.getenv("AAMNE_VERSION", "aamne23")
path_data_aamne <- paste0(ifelse(aamne_version == "icio2026", "oecd_icio/", "oecd_aamne/"), aamne_version, "/")
# folder of the yearly CSVs: flat under RAW_DATA; DATA_SOURCES keeps the layout of the OECD downloads (gmrio/, ICIO: gmrio/CurrentPrices/)
path_data_aamne <- if (DATA_FROM_SOURCES) {
  paste0(DATA_SOURCES, path_data_aamne, "gmrio/", ifelse(aamne_version == "icio2026", "CurrentPrices/", ""))
} else paste0(RAW_DATA, path_data_aamne)

###### INITIATE LOOP
# years available in the raw CSV data: AAMNE_ICIO<YYYY>.csv, <YYYY>_SML.csv, <YYYY>_PROJECTED.csv
vctr_allyears <- sort(unique(sub("^(AAMNE_ICIO)?([0-9]{4}).*$", "\\2", list.files(
  path = path_data_aamne, pattern = "^(AAMNE_ICIO)?[0-9]{4}(_SML|_PROJECTED)?\\.csv$"))))

foreach(
  i=vctr_allyears,
  .packages=c("readr","tidyr","dplyr")) %dopar% { # START of loop

#i<-c("2010")

# ##@## check data availability
data_avlblty_i <- list.files(
  path = paste0(file.path(PIPELINE_DIR,"R_aamne_decompr","tmp")),
  pattern = paste0("^.*", i, "\\.rds$"),
  full.names = TRUE)
#
if (length(data_avlblty_i) == 0) {
    print(paste0("Data unavailable for year ", i, ": no data-prep output in ", file.path(PIPELINE_DIR,"R_aamne_decompr","tmp","")))
    return(NULL)
  }
# ##$##

# ##@## Load data
countries_aamne <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_countries_",i,".rds"))
#
industries_aamne <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_industries_",i,".rds"))
#
aamne_z_i_matrix <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_z_",i,"_matrix.rds"))
#
aamne_f_i_matrix <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_f_",i,"_matrix.rds"))
#
aamne_go_i_vector <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_go_",i,"_vector.rds"))
#
aamne_va_i_vector <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
  "data_aamne_va_",i,"_vector.rds"))
#
aamne_gva_i_vector <- readRDS(paste0(file.path(
  PIPELINE_DIR,"R_aamne_decompr","tmp",""),
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
  # Interpretation: the go vector from aamne is not identical to
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

#stop cluster
stopCluster(cl)

##### join and export

# ##@## collect estimates: decomp_aamne_wwz
setwd(file.path(pipeline, "store"))
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

# restore the original working directory (changed in PREAMBLE: 2 Settings)
setwd(WD_ORIG)
