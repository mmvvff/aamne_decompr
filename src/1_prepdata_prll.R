# Introduction: Prepare AAMNE (v23 or v26) or ICIO (2026) data for decompr
# clear the console
cat("\f")
# ##@## PREAMBLE: Environment ####

#.rs.restartR()

# clear the environment
rm(list = ls())

# clear cache
gc(full = TRUE)

# clear the console
cat("\f")

# Imports: All the library imports go here

library(readr)
library(tidyr)
library(dplyr)
library(foreach)
library(doParallel)
library(conflicted)
# ##$##

# ##@## PREAMBLE: 2 Settings ####
NAME <- "R_aamne_decompr"
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

# version: "aamne23", "aamne26" (aAMNE) or "icio2026" (ICIO, no ownership split); override via env var AAMNE_VERSION
aamne_version <- Sys.getenv("AAMNE_VERSION", "aamne23")
path_data_aamne <- paste0(
  ifelse(aamne_version == "icio2026", "oecd_icio/", "oecd_aamne/"),
  aamne_version,
  "/"
)
# folder of the yearly CSVs: flat under RAW_DATA; DATA_SOURCES keeps the layout of the OECD downloads (gmrio/, ICIO: gmrio/CurrentPrices/)
path_data_aamne <- if (DATA_FROM_SOURCES) {
  paste0(
    DATA_SOURCES,
    path_data_aamne,
    "gmrio/",
    ifelse(aamne_version == "icio2026", "PYP/", "")
  )
} else {
  paste0(RAW_DATA, path_data_aamne)
}

# ##@## OECD LABELS for VECTORS OF MATRICES
# ##@## aamne23
vctr_aamne23_io_fnldmnd <- c("HFCE", "NONRES", "NPISH", "GGFC", "GFCF", "INVNT")
vctr_aamne23_io_govatax <- c("GVA", "TAXSUB", "GO")
# ##$##
# ##@## aamne26
vctr_aamne26_io_fnldmnd <- c("HFCE", "NPISH", "GGFC", "GFCF", "INVNT", "DPABR")
vctr_aamne26_io_govatax <- c("GVA", "TAXSUB", "GO")
# ##$##
vctr_aamne_io_fnldmnd <- union(vctr_aamne23_io_fnldmnd, vctr_aamne26_io_fnldmnd)
vctr_aamne_io_govatax <- union(vctr_aamne23_io_govatax, vctr_aamne26_io_govatax)
# final demand labels of the selected version (icio2026 has the aamne26 labels)
vctr_aamne_vrsn_io_fnldmnd <- if (aamne_version == "aamne23") {
  vctr_aamne23_io_fnldmnd
} else {
  vctr_aamne26_io_fnldmnd
}
# ##$##

#setup parallel backend: one worker per 4 GB of RAM, after reserving 2 GB (at least 1)
ram_gb <- if (file.exists("/proc/meminfo")) {
  as.numeric(gsub(
    "\\D",
    "",
    grep("MemTotal", readLines("/proc/meminfo"), value = TRUE)
  )) /
    1024^2
} else {
  as.numeric(system("sysctl -n hw.memsize", intern = TRUE)) / 1024^3
}
cl <- makeCluster(max(1, floor((ceiling(ram_gb) - 2) / 4)), outfile = "")
registerDoParallel(cl)

###### INITIATE LOOP
# years available in the raw CSV data: AAMNE_ICIO<YYYY>.csv, <YYYY>_SML.csv, <YYYY>_PROJECTED.csv
vctr_allyears <- sort(unique(sub(
  "^(AAMNE_ICIO|ICIO_PYP_)?([0-9]{4}).*$",
  "\\2",
  list.files(
    path = path_data_aamne,
    pattern = "^(AAMNE_ICIO|ICIO_PYP_)?[0-9]{4}(_SML|_PROJECTED)?\\.csv$"
  )
)))

foreach(
  i = vctr_allyears,
  .packages = c("readr", "tidyr", "dplyr")
) %dopar%
  {
    # START of loop

    #i<-c("2010")

    # ##@## Load data: AAMNE

    # ICIO
    # we load Rdata icio

    aamne_io_i <- list.files(
      path = path_data_aamne,
      pattern = paste0("^(AAMNE_ICIO)?", i, "(_SML|_PROJECTED)?\\.csv$"),
      full.names = TRUE
    )
    #
    if (length(aamne_io_i) == 0) {
      print(paste("Data unavailable for year", i))
      return(NULL)
    }

    aamne_io_i_tbl <- readr::read_csv(aamne_io_i)

    # ##@## confirm AAMNE version

    ##### Expected dimensions of each version

    # rows: countries x 2 ownership types x 41 sectors (ICIO: countries x 50 sectors), plus 3 aggregate rows
    # columns: row names, one per sector row, countries x 6 final demand components (ICIO: plus total output)
    dim_aamne <- switch(
      aamne_version,
      aamne23 = c(6317, 6777), # 77 countries
      aamne26 = c(6645, 7129), # 81 countries
      icio2026 = c(4053, 4538)
    ) # 81 countries

    if (
      aamne_version %in%
        c("aamne23", "aamne26") &&
        all(dim(aamne_io_i_tbl) == dim_aamne)
    ) {
      # sector codes with an underscore are renamed (D35_E36T39 = D35TE36T39) in column names and
      # row labels, so that separate() below does not split them
      aamne_io_i_tbl <- aamne_io_i_tbl %>%
        rename(cntry_own_sctr = "...1") %>%
        dplyr::rename_with(
          ~ stringr::str_replace_all(.x, "D35_E36T39", "D35TE36T39")
        ) %>%
        dplyr::mutate(
          cntry_own_sctr = stringr::str_replace_all(
            cntry_own_sctr,
            "D35_E36T39",
            "D35TE36T39"
          )
        ) %>%
        tidyr::separate(
          cntry_own_sctr,
          into = c("cntry", "ownrshp", "sctr"),
          sep = "_",
          extra = "merge"
        )
    } else if (
      aamne_version == "icio2026" && all(dim(aamne_io_i_tbl) == dim_aamne)
    ) {
      # ICIO: no ownership split; row names in "V1" (SML) or "id" (PROJECTED);
      # the last row and column report total output: "OUT" (SML) or "TOTAL" (PROJECTED)
      # aggregate rows take the aAMNE labels: TLS = TAXSUB, VA = GVA, OUT/TOTAL = GO
      # sector codes with an underscore are renamed (J62_63 = J62T63, C17_18 = C17T18) in column names and
      # row labels, so that separate() below does not split them
      aamne_io_i_tbl <- aamne_io_i_tbl %>%
        dplyr::rename_with(~"cntry_sctr", .cols = any_of(c("V1", "id"))) %>%
        dplyr::select(!any_of(c("OUT", "TOTAL"))) %>%
        dplyr::rename_with(
          ~ stringr::str_replace_all(
            .x,
            c(
              "J62_63" = "J62T63",
              "C17_18" = "C17T18"
            )
          )
        ) %>%
        dplyr::mutate(
          cntry_sctr = dplyr::recode(
            cntry_sctr,
            TLS = "TAXSUB",
            VA = "GVA",
            OUT = "GO",
            TOTAL = "GO"
          )
        ) %>%
        dplyr::mutate(
          cntry_sctr = stringr::str_replace_all(
            cntry_sctr,
            c(
              "J62_63" = "J62T63",
              "C17_18" = "C17T18"
            )
          )
        ) %>%
        tidyr::separate(
          cntry_sctr,
          into = c("cntry", "sctr"),
          sep = "_",
          extra = "merge"
        )
    } else {
      stop(
        "not ICIO-AAMNE ",
        aamne_version,
        " (AAMNE_VERSION): ",
        basename(aamne_io_i),
        " is ",
        paste(dim(aamne_io_i_tbl), collapse = "x")
      )
    }

    # ##$##

    # ##$##

    # ##@## Recode data

    # We Rename columns names of Final Demand to fit 3 pieces
    aamne_io_i_tbl <- aamne_io_i_tbl %>%
      rename_with(
        ~ gsub("_", "_fnldmnd_", .x, fixed = TRUE),
        .cols = contains(paste(vctr_aamne_io_fnldmnd))
      )
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
      # (ICIO has no ownership: the industry is the sector alone)
      tidyr::unite("own_sctr", any_of(c("ownrshp", "sctr")), sep = "_") %>%
      dplyr::relocate(cntry, own_sctr) %>%
      dplyr::arrange(cntry, own_sctr) %>% # sort rows to match order in columns
      dplyr::select(cntry, own_sctr, sort(names(.))) # sort columns to match order in rows

    # confirm order of country-own-industry in rows vs. columns
    aamne_z_i
    aamne_z_i[, (ncol(aamne_z_i) - 6 - 1):ncol(aamne_z_i)]
    # ##$##

    # ##@## test: vector of countries and industries
    # countries
    countries_z_source <- unique(aamne_z_i$cntry)
    countries_z_dest <- unique(
      stringr::str_extract(
        names(aamne_z_i[, !names(aamne_z_i) %in% c("cntry", "own_sctr")]),
        "[A-Z]{3}"
      )
    )

    stopifnot(exprs = {
      all.equal(countries_z_source, countries_z_dest)
    })
    countries_z <- intersect(countries_z_source, countries_z_dest)

    # industries
    industries_z_source <- unique(aamne_z_i$own_sctr)
    industries_z_dest <- unique(
      stringr::str_match(
        names(aamne_z_i[, !names(aamne_z_i) %in% c("cntry", "own_sctr")]),
        "[A-Z]{3}_([0-9A-Z_]+)"
      )[, 2]
    )
    #
    stopifnot(exprs = {
      all.equal(industries_z_source, industries_z_dest)
    })
    industries_z <- intersect(industries_z_source, industries_z_dest)
    # ##$##

    # ##@## output: aamne_z_i_matrix

    aamne_z_i_matrix <- aamne_z_i %>%
      dplyr::select(!c(cntry, own_sctr)) %>%
      as.matrix(.) %>%
      unname(.)

    # ##$##

    # ##$##

    # ##@## final demand matrix: f

    # ##@## prepare
    aamne_f_i <- aamne_io_i_tbl %>%
      dplyr::select(cntry, any_of("ownrshp"), sctr, contains("fnldmnd")) %>% # include final demand components
      dplyr::filter(!sctr %in% vctr_aamne_io_govatax) %>% # remove aggregates
      dplyr::filter(!cntry %in% vctr_aamne_io_govatax) %>% # remove aggregates
      # although the above two are equivalent to drop_na(), they more readable
      # tidyr::drop_na() %>%
      # combine ownership and industry into single industry
      # (ICIO has no ownership: the industry is the sector alone)
      tidyr::unite("own_sctr", any_of(c("ownrshp", "sctr")), sep = "_") %>%
      dplyr::relocate(cntry, own_sctr) %>%
      dplyr::arrange(cntry, own_sctr) %>% # sort rows to match order in columns
      dplyr::select(cntry, own_sctr, sort(names(.))) # sort columns to match order in rows

    # confirm order of country-own-industry in rows vs. columns
    aamne_f_i
    aamne_f_i[, (ncol(aamne_f_i) - 2 - 1):ncol(aamne_f_i)]
    # ##$##

    # ##@## vector of countries and industries
    # producers: input buyers and source of FD
    countries_f_source <- unique(aamne_f_i$cntry)
    # consumers: destination of FD
    countries_f_dest <- unique(
      stringr::str_extract(
        names(aamne_f_i[, !names(aamne_f_i) %in% c("cntry", "own_sctr")]),
        "[A-Z]{3}"
      )
    )
    # test
    stopifnot(exprs = {
      all.equal(countries_f_source, countries_f_dest)
    })
    # output
    countries_f <- intersect(countries_f_source, countries_f_dest)

    # producers: input buyers and source of FD
    industries_f <- unique(aamne_f_i$own_sctr)

    # consumers: destination of FD
    components_f <- unique(
      stringr::str_match(
        names(aamne_f_i[, !names(aamne_f_i) %in% c("cntry", "own_sctr")]),
        "[a-z]+_([0-9A-Z]+)"
      )[, 2]
    )
    # test
    stopifnot(exprs = {
      all.equal(components_f, sort(vctr_aamne_vrsn_io_fnldmnd))
    })
    # ##$##

    # ##@## matrix: aamne_f_i_matrix
    aamne_f_i_matrix <- aamne_f_i %>%
      dplyr::select(!c(cntry, own_sctr)) %>%
      as.matrix(.) %>%
      unname(.)
    dim(aamne_f_i_matrix)
    # ##$##

    # ##$##

    # ##@## gross output vector: go

    # ##@## prepare
    if (all(dim(aamne_io_i_tbl)[1] == dim_aamne[1])) {
      aamne_go_i <- aamne_io_i_tbl %>%
        dplyr::select(!contains("fnldmnd")) %>% # remove final demand components
        dplyr::filter(cntry %in% c("GO")) %>% # focus on go
        dplyr::select(!any_of(c("sctr", "ownrshp"))) %>%
        dplyr::select(cntry, sort(names(.))) # sort columns
    } else {
      print("not ICIO-AAMNE")
    }

    # confirm order of country-own-industry in rows vs. columns
    aamne_go_i
    aamne_go_i[, (ncol(aamne_go_i) - 2 - 1):ncol(aamne_go_i)]
    # ##$##

    # ##@## vector of countries and industries

    # countries:
    # producers: input buyers and source of FD
    countries_go <- unique(
      stringr::str_extract(
        names(aamne_go_i[, !names(aamne_go_i) %in% c("sctr")]),
        "[A-Z]{3}"
      )
    )
    #
    industries_go <- unique(
      stringr::str_match(
        names(aamne_go_i[, !names(aamne_go_i) %in% c("sctr")]),
        "[A-Z]{3}_([0-9A-Z_]+)"
      )[, 2]
    )

    # ##$##

    # ##@## matrix: aamne_go_i_vector
    aamne_go_i_vector <- aamne_go_i %>%
      dplyr::select(!where(is.character)) %>%
      dplyr::slice(1) %>%
      as.numeric(.)
    # ##$##

    # ##$##

    # ##@## gross output vector: va

    # ##@## prepare
    if (all(dim(aamne_io_i_tbl)[1] == dim_aamne[1])) {
      aamne_va_i <- aamne_io_i_tbl %>%
        dplyr::select(cntry, !contains("fnldmnd")) %>% # remove final demand components
        dplyr::filter(cntry %in% c("GVA")) %>% # focus on go
        dplyr::select(!any_of(c("sctr", "ownrshp"))) %>%
        dplyr::select(cntry, sort(names(.))) # sort columns
    } else {
      print("not ICIO-AAMNE")
    }

    # confirm order of country-own-industry in rows vs. columns
    aamne_va_i
    aamne_va_i[, (ncol(aamne_va_i) - 2 - 1):ncol(aamne_va_i)]
    # ##$##

    # ##@## vector of countries and industries

    # countries:
    # producers: input buyers and source of output
    countries_va <- unique(
      stringr::str_extract(
        names(aamne_va_i[, !names(aamne_va_i) %in% c("sctr")]),
        "[A-Z]{3}"
      )
    )
    #
    industries_va <- unique(
      stringr::str_match(
        names(aamne_va_i[, !names(aamne_va_i) %in% c("sctr")]),
        "[A-Z]{3}_([0-9A-Z_]+)"
      )[, 2]
    )

    # ##$##

    # ##@## matrix: aamne_va_i_vector
    aamne_va_i_vector <- aamne_va_i %>%
      dplyr::select(!where(is.character)) %>%
      dplyr::slice(1) %>%
      as.numeric(.)
    # ##$##

    # ##$##

    # ##@## gross output vector: gva

    # ##@## prepare
    if (all(dim(aamne_io_i_tbl)[1] == dim_aamne[1])) {
      aamne_gva_i <- aamne_io_i_tbl %>%
        dplyr::select(cntry, !contains("fnldmnd")) %>% # remove final demand components
        dplyr::filter(cntry %in% c("GVA", "TAXSUB")) %>% # focus on VA
        dplyr::select(!any_of(c("cntry", "ownrshp", "sctr"))) %>%
        dplyr::summarize(across(.cols = where(is.numeric), .fns = sum)) %>%
        tibble::add_column(sctr = c("GVA"), .before = 1) %>%
        dplyr::select(sctr, sort(names(.))) # sort columns to match order in rows
    } else {
      print("not ICIO-AAMNE")
    }

    any(is.na(aamne_gva_i))
    aamne_gva_i
    # confirm order of country-own-industry in rows vs. columns
    aamne_gva_i
    aamne_gva_i[, (ncol(aamne_gva_i) - 2 - 1):ncol(aamne_gva_i)]
    # ##$##

    # ##@## vector of countries and industries

    # countries:
    # producers: input buyers and source of output
    countries_gva <- unique(
      stringr::str_extract(
        names(aamne_gva_i[, !names(aamne_gva_i) %in% c("sctr")]),
        "[A-Z]{3}"
      )
    )
    #
    industries_gva <- unique(
      stringr::str_match(
        names(aamne_gva_i[, !names(aamne_gva_i) %in% c("sctr")]),
        "[A-Z]{3}_([0-9A-Z_]+)"
      )[, 2]
    )

    # ##$##

    # ##@## matrix: aamne_gva_i_vector
    aamne_gva_i_vector <- aamne_gva_i %>%
      dplyr::select(!where(is.character)) %>%
      dplyr::slice(1) %>%
      as.numeric(.)
    # ##$##

    # ##$##

    # ##@## TEST decompr requirements: order and size of countries and industries

    # countries and industries identical across z, f, GO, VA, GVA
    # (setdiff drops the NA that label columns yield)
    stopifnot(exprs = {
      length(unique(lapply(
        list(
          countries_z,
          countries_f,
          countries_go,
          countries_va,
          countries_gva
        ),
        setdiff,
        NA
      ))) ==
        1
      length(unique(lapply(
        list(
          industries_z,
          industries_f,
          industries_go,
          industries_va,
          industries_gva
        ),
        setdiff,
        NA
      ))) ==
        1
    })

    countries_aamne <- Reduce(
      intersect,
      list(countries_z, countries_f, countries_go, countries_va, countries_gva)
    )

    industries_aamne <- Reduce(
      intersect,
      list(
        industries_z,
        industries_f,
        industries_go,
        industries_va,
        industries_gva
      )
    )
    # ##$##

    # ##@## TEST decompr requirements: size of matrices and vectors
    # z is square; f rows and GO/VA/GVA entries: one per country-industry
    stopifnot(exprs = {
      length(unique(c(
        dim(aamne_z_i_matrix),
        nrow(aamne_f_i_matrix),
        length(aamne_go_i_vector),
        length(aamne_va_i_vector),
        length(aamne_gva_i_vector),
        length(countries_aamne) * length(industries_aamne)
      ))) ==
        1
    })

    if (all(dim(aamne_io_i_tbl)[1] == dim_aamne[1])) {
      stopifnot(exprs = {
        all.equal(
          dim(aamne_f_i_matrix)[2],
          length(countries_aamne) * length(vctr_aamne_vrsn_io_fnldmnd)
        )
      })
    }
    # ##$##

    # ##@## TEST: supplied vs matrix-implied GO/GVA (README "Methodological note")
    # decompr rejects o/v vectors inconsistent with the matrices, so GO/VA are
    # derived from z/f; aAMNE's supplied vectors differ slightly from them
    # (observed mean rel. diff ~2.3e-06 GO, ~2.4e-08 GVA). Warn if a future aAMNE
    # release drifts past 1e-5, i.e. decompr totals no longer approximate aAMNE's.
    go_implied <- rowSums(aamne_z_i_matrix) + rowSums(aamne_f_i_matrix)
    go_reldiff <- mean(abs(aamne_go_i_vector - go_implied)) /
      mean(abs(go_implied))
    gva_implied <- go_implied - colSums(aamne_z_i_matrix)
    gva_reldiff <- mean(abs(aamne_gva_i_vector - gva_implied)) /
      mean(abs(gva_implied))
    if (go_reldiff > 1e-5 || gva_reldiff > 1e-5) {
      warning(
        "aAMNE year ",
        i,
        ": supplied-vs-implied mean rel. diff exceeds 1e-5 ",
        "(GO: ",
        signif(go_reldiff, 3),
        "; GVA: ",
        signif(gva_reldiff, 3),
        "). ",
        "decompr's matrix-implied totals diverge from aAMNE's published GO/GVA."
      )
    }
    # ##$##

    # ##@## Save
    # countries_aamne
    saveRDS(
      countries_aamne,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_countries_",
        i,
        ".rds"
      )
    )
    #
    # industries_aamne
    saveRDS(
      industries_aamne,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_industries_",
        i,
        ".rds"
      )
    )

    # aamne_z_i_matrix
    saveRDS(
      aamne_z_i_matrix,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_z_",
        i,
        "_matrix.rds"
      )
    )

    # aamne_f_i_matrix
    saveRDS(
      aamne_f_i_matrix,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_f_",
        i,
        "_matrix.rds"
      )
    )

    # aamne_go_i_vector
    saveRDS(
      aamne_go_i_vector,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_go_",
        i,
        "_vector.rds"
      )
    )

    # aamne_va_i_vector
    saveRDS(
      aamne_va_i_vector,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_va_",
        i,
        "_vector.rds"
      )
    )

    # aamne_gva_i_vector
    saveRDS(
      aamne_gva_i_vector,
      file = paste0(
        file.path(pipeline, "tmp", ""),
        "data_aamne_gva_",
        i,
        "_vector.rds"
      )
    )

    # ##$##
  }

#stop cluster
stopCluster(cl)

# restore the original working directory (changed in PREAMBLE: 2 Settings)
setwd(WD_ORIG)
