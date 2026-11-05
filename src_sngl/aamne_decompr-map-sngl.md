# REPOSITORY MAP: aamne_decompr, single-core subset (src_sngl)

## 0. Map metadata

- Repository: local clone at `prgrmmng/git_repos/econ/aamne_decompr` (GitHub: `mmvvff/aamne_decompr`, per README.md "Usage" step 1)
- Subject: `src_sngl/`, the single-core subset of `src/` (21 R scripts) and the repository-root files it depends on (`README.md`, `data_urls/`, `LICENSE`, `.gitignore`)
- Derived from: `aamne_decompr-map.md`, the parent map of the whole repository (verified at HEAD `6a51095`); supplied outside the repository, not tracked
- Verified against: branch `mmvvff/affectionate-keller-8bmxk8` at `a3144fc` (base `6a51095`), PR mmvvff/aamne_decompr#3; `src_sngl/` holds 22 files (21 R scripts and this map)
- Last verified: 2026-11-05
- Audience: maintainers of this repository (human and AI). Researcher-facing setup guidance lives in README.md.
- Scope: files inside the repository only (code, README, data_urls; the `src/0_ubuntu_example_run/example-*-readme.md` walkthroughs are cited for runtimes only). Do not follow external links or papers.
- Conventions: Sections 1-4 and 7 describe the current state. Section 5 lists open limitations (L#). Section 6 is history only: resolved repository items (R#), map revisions (M#), and applied map evaluation items (E#).
- Format: Markdown headings and tables; one fact per row or bullet; paths relative to the repository root unless they start with `~`.

## 1. Purpose

- What: implements the value-added (VA) trade accounting framework of Wang, Wei & Zhu (2013), "WWZ", on the OECD Analytical AMNE (aAMNE) database (Activities of Multinational Enterprises / Global Value Chains). Source: README.md lines 1-13.
- Data preparation follows Miroudot & Ye (2019: 14). Source: README.md "Overview" item 1.
- Engine: the CRAN `decompr` package performs the decomposition; this repository supplies data preparation, input modification, and post-processing around it.
- Research use case: quantify VA embodied in gross trade flows by country and origin sector, for GVC and multinational-enterprise research in economic development. Source: README.md "Overview" closing sentence and "Contributing" (GVC analysis of NRR and tech-intensive sectors).
- Distinctive contribution: VA-trade content for specific sector-to-sector relations, obtained by zeroing entries of decompr's `Vc` vector before `wwz()` (component C). Source: README.md "Sector Aggregation Logic".
- Subset: `src_sngl/` holds only the single-core workflow of `src/`: the single-core scripts (`1_prepdata_sngl.R`, `*_sngl_all.R`) and the single-core batch scripts (`*_sngl_btch_YY-YY.R`, `*_sngl_btch_end.R`). Parallel scripts and Ubuntu orchestration stay in `src/` (Section 2.7).
- Form: standalone R scripts, NOT an installable R package. No DESCRIPTION, NAMESPACE, R/, man/, tests/, vignettes/, or docs/ directory. Scripts run via `Rscript -e 'source("path/to/script.R")'` (Section 7.6).

## 2. Repository structure

### 2.1 Top level

| Path | Role |
|---|---|
| `README.md` | Researcher guide for the whole repository. Sections in order: Overview, Dependencies, Folder structure and data, Usage, Notes for researchers, Sector Aggregation Logic (with "Classification-flag reference (draft)"), Methodological note, Structure, Contributing, Citation, License. Its commands name `src/` paths |
| `LICENSE` | MIT License text |
| `.gitattributes` | `* text=auto` (LF normalization) |
| `.gitignore` | Standard R template plus `.DS_Store` and root-anchored `/0_data/`, `/2_pipeline/`, `/3_output/` (R31) |
| `data_urls/` | Download URL lists and sector classification CSVs (Section 2.2) |
| `src/` | Full code base (single-core, parallel, batch, Ubuntu orchestration); origin of every `src_sngl/` script |
| `src_sngl/` | Single-core subset of `src/` (Sections 2.3-2.6) |

### 2.2 data_urls/

| File | Role |
|---|---|
| `codes_sector_oecd_aamneV18_classification.csv` | Sector classification, aAMNE v18: 18 columns, 34 sector rows (35 lines incl. header), no trailing newline |
| `codes_sector_oecd_aamneV23_classification.csv` | Sector classification, aAMNE v23: 16 columns, 41 sector rows (42 lines incl. header), no trailing newline |
| `url_aamne23.txt` | 24 static OECD download URLs for aAMNE 2023 (one per line); read only by `src/0_ubuntu_example_run/helpers/0_ubuntu_setup_data.bash` (not in `src_sngl/`) |
| `url_aamne23.tsv` | Same 24 URLs preceded by a `TsvHttpData-1.0` header line |

- Shared columns (both CSVs): `sector_code`, `sector_disaggrgt_name`, `sector_aggrgt_name_spplrs`, `sector_aggrgt_name_prdcrs`, and flags `mnfctrng_users`, `nrr_vc_prdcrs`, `nrr_upstrm_prdcrs`, `nrr_dwnstrm_prdcrs`, `mnfctrng_prdcrs`, `apparel_prdcrs`, `elctrncs_prdcrs`, `autmtv_prdcrs`, `tradables_mx`, `tradables_sx`, `nontrdbls_sx`, `techrnd_highmed`.
- V18-only columns: `nontrdbls_cns`, `nontrdbls_scl`.
- Flag values: `1` or blank (no `0` cells); blanks read as NA, and `dplyr::filter(<flag>==1)` drops them.
- No sector code is a suffix of another code in either CSV (relevant to cousec's suffix regex `(<code>)$`, Section 3.C).
- Only V23 code `D35_E36T39` contains `_`; `src_sngl/` keeps it whole in every label (R32).
- Label columns (`sector_disaggrgt_name`, `sector_aggrgt_name_spplrs`, `sector_aggrgt_name_prdcrs`) are read by no script. V23 `sector_aggrgt_name_prdcrs` equals the V18 label of the corresponding sector in all 41 rows; V18 row B is named "Mining and quarrying" (R30).
- No URL list is provided for aAMNE v18.
- Read location: cousec and indexed scripts read the CSV from `AAMNE_RAW_DATA` (default `0_data/`), not from `data_urls/`.

### 2.3 src_sngl/ (top level)

| File | Role |
|---|---|
| `1_prepdata_sngl.R` | Component A, single-core, 2000:2020 |
| `aamne_decompr-map-sngl.md` | This map |

- Provenance: every R script in `src_sngl/` was copied byte-identical from `src/<same relative path>` at HEAD `6a51095` (checked with `cmp`), then edited in place by R32-R34 (Section 6.1); all 21 now differ from `src/` at those lines only. `src/` is unchanged.
- Layout: the `src/` relative paths are kept, including the folder name `bash_prll/`. No dispatcher is copied, so `src_sngl/` batch files run one after another (Section 7.6).

### 2.4 src_sngl/1_transform_indexed_example/ (Component D)

| File | Role |
|---|---|
| `1_trnsfrm_indexed_sngl_all.R` | Single-core, 2000:2020 |
| `bash_prll/0_trnsfrm_indexed_sngl_btch_00-04.R` | Batch 2000:2004 |
| `bash_prll/0_trnsfrm_indexed_sngl_btch_05-09.R` | Batch 2005:2009 |
| `bash_prll/0_trnsfrm_indexed_sngl_btch_10-14.R` | Batch 2010:2014 |
| `bash_prll/0_trnsfrm_indexed_sngl_btch_15-17.R` | Batch 2015:2017 |
| `bash_prll/0_trnsfrm_indexed_sngl_btch_18-20.R` | Batch 2018:2020 |

- The 5 batch files are identical to `1_trnsfrm_indexed_sngl_all.R` except the `vctr_allyears` line.

### 2.5 src_sngl/cou/ (Component B)

| File | Role |
|---|---|
| `2_decompr_cou_sngl_all.R` | Single-core, 2000:2020, includes consolidation |
| `bash_prll/2_decompr_cou_sngl_btch_00-04.R` | Batch 2000:2004, per-year files only |
| `bash_prll/2_decompr_cou_sngl_btch_05-09.R` | Batch 2005:2009, per-year files only |
| `bash_prll/2_decompr_cou_sngl_btch_10-14.R` | Batch 2010:2014, per-year files only |
| `bash_prll/2_decompr_cou_sngl_btch_15-17.R` | Batch 2015:2017, per-year files only |
| `bash_prll/2_decompr_cou_sngl_btch_18-20.R` | Batch 2018:2020, per-year files only |
| `bash_prll/2_decompr_cou_sngl_btch_end.R` | Consolidator: binds `store/` files into `out/decomp_aamne_wwz_cou.rds` |

- Batch files equal `2_decompr_cou_sngl_all.R` except the year line, the consolidation block (replaced by `warnings()`), and a `# END of loop` comment on the loop's closing brace.

### 2.6 src_sngl/cousec/ (Component C)

| File | Role |
|---|---|
| `2_decompr_cousec_sngl_all.R` | Single-core, 2000:2020, includes consolidation |
| `bash_prll/2_decompr_cousec_sngl_btch_00-04.R` | Batch 2000:2004, per-year files only |
| `bash_prll/2_decompr_cousec_sngl_btch_05-09.R` | Batch 2005:2009, per-year files only |
| `bash_prll/2_decompr_cousec_sngl_btch_10-14.R` | Batch 2010:2014, per-year files only |
| `bash_prll/2_decompr_cousec_sngl_btch_15-17.R` | Batch 2015:2017, per-year files only |
| `bash_prll/2_decompr_cousec_sngl_btch_18-20.R` | Batch 2018:2020, per-year files only |
| `bash_prll/2_decompr_cousec_sngl_btch_end.R` | Consolidator: re-reads the classification CSV, binds `store/` files into the 8 `out/` files |

- The 5 batch files are identical to each other except for the year line.
- Versus `2_decompr_cousec_sngl_all.R`, the batches omit the consolidation block, clear the console at line 3 instead of after `gc()`, add `Sys.sleep(1)` after `gc()`, and start each loop pass with `Sys.sleep(1)` and `cat("\n")` instead of `Sys.sleep(0.5)`.

### 2.7 Excluded from src_sngl/ (kept in src/)

| Path | Reason |
|---|---|
| `src/1_prepdata_prll.R` | Multi-processor: `foreach %dopar%` on a `makeCluster(detectCores()-1)` cluster |
| `src/cou/2_decompr_cou_prll.R` | Multi-processor: `foreach %dopar%` on a `makeCluster(detectCores()-2)` cluster |
| `src/cousec/2_decompr_cousec_prll.R` | Multi-processor: as cou prll |
| `src/1_transform_indexed_example/1_trnsfrm_indexed_prll.R` | Multi-processor: as cou prll; ~20GB RAM per year (`src/0_ubuntu_example_run/example-indexed-readme.md`) |
| `src/parallel_example.R` | Multi-processor cluster fragment; referenced by no file |
| `src/0_ubuntu_example_run/` (22 files) | Orchestration: its 3 dispatchers start all 5 batch files of a component at once (`sudo nohup Rscript ... &` in a loop), and its wrappers download `src/` scripts from GitHub `main` |

### 2.8 Batch coverage

| Component | 00-04 | 05-09 | 10-14 | 15-17 | 18-20 | Coverage |
|---|---|---|---|---|---|---|
| cou | 2000:2004 | 2005:2009 | 2010:2014 | 2015:2017 | 2018:2020 | Complete 2000-2020 |
| cousec | 2000:2004 | 2005:2009 | 2010:2014 | 2015:2017 | 2018:2020 | Complete 2000-2020 |
| indexed | 2000:2004 | 2005:2009 | 2010:2014 | 2015:2017 | 2018:2020 | Complete 2000-2020 |

- Naming: all batch files end `_sngl_btch_YY-YY.R`. Prefixes differ: `2_decompr_cou_`, `2_decompr_cousec_`, `0_trnsfrm_indexed_`.
- History: Section 6.1 R1, R3.

## 3. Component breakdown

### 3.A Data preparation

- Objective: build the per-year matrices and vectors that decompr needs from raw aAMNE ICIO CSVs.
- Key files: `src_sngl/1_prepdata_sngl.R`
- Key functions: `readr::read_csv()`, `tidyr::separate()` (v23 row labels), `dplyr` select/filter/arrange, `stringr::str_extract()`/`str_match()` (country and industry vectors), `saveRDS()`
- Pipeline NAME: `R_aamne_decompr` (writes `2_pipeline/R_aamne_decompr/tmp/`)
- Year loop: 2000:2020. A missing year prints "Data unavailable for year <i>" and is skipped with `next`. The same applies to components B, C, D.
- Processing: ownership (`own`) and sector (`ind`) are concatenated into one `own_sctr` dimension, so decompr "industries" = ownership x sector (68 in v18, 82 in v23).
- Labels: v23 row labels are split with `tidyr::separate(sep = "_", extra = "merge")`, and industries are read from column names with `[A-Z]{3}_([A-Z]{1}_[0-9A-Z_]+)`, so sector `D35_E36T39` stays whole (R32). The 3 aggregate rows (GVA, TAXSUB, GO) still raise tidyr's "Missing pieces filled with `NA`" warning.
- Checks: 9 `stopifnot()` sites. The 2-argument checks (z and f country/industry order, final-demand components, f column count) compare both arguments. The countries/industries block requires the 5 country and the 5 industry vectors (z, f, GO, VA, GVA) to be identical after `setdiff(., NA)`, which drops the NA that label columns yield. The size block requires `dim(z)`, `nrow(f)`, the GO/VA/GVA lengths, and countries x industries to be equal (R25).
- GO/GVA drift guard: implied GO = `rowSums(z) + rowSums(f)`, compared with the GO vector (`data_aamne_go`); implied VA = implied GO - `colSums(z)`, compared with the GVA + TAX/TAXSUB vector (`data_aamne_gva`), not the GVA-row vector (`data_aamne_va`). Calls `warning()` when either mean relative difference exceeds 1e-5 (L1).
- Version: `AAMNE_VERSION` selects the input folder, and the load-time branch requires the table dimensions to match it (v18: 4083x4443; v23: 6317x6777). Otherwise it stops with `not ICIO-AAMNE <version> (AAMNE_VERSION): <file> is <rows>x<cols>` (R22, R27). Four later checks keep a `print()` in their unreachable `else`: the final-demand component check keyed on 68/82 industries (`print("Not ICIO-AAMNE")`) and the 3 GO/VA/GVA row-count checks (`print("not ICIO-AAMNE")`). The same applies to component D.
- Version-specific labels: final demand v18 HFCE, NPISH, GGFC, GFCF, INVNT, P33; v23 HFCE, NONRES, NPISH, GGFC, GFCF, INVNT. Aggregate rows v18 GVA, TAX, GO; v23 GVA, TAXSUB, GO.
- Resources: runtime and memory not documented in the repository.

### 3.B Country-level decomposition (cou)

- Objective: standard decompr use case; VA contributions from the whole economy (all origin sectors) to each destination sector ("typical approach of decompr", README.md "Usage" step 4).
- Key files: `src_sngl/cou/2_decompr_cou_sngl_all.R`, `src_sngl/cou/bash_prll/*`
- Key functions: `decompr::load_tables_vectors()`, `decompr::wwz()`
- Pipeline NAME: `R_aamne_decompr_cou` in all 7 cou scripts
- Year loop: 2000:2020 (sngl_all); batches per Section 2.8. A year is skipped when `2_pipeline/R_aamne_decompr/tmp/` has no `.rds` file whose name ends in the year (A's output), not when the raw CSV is absent; it prints `Data unavailable for year <i>: no data-prep output in 2_pipeline/R_aamne_decompr/tmp/` (R33).
- Processing: `load_tables_vectors(x=z, y=f, k=countries, i=industries, null_inventory=FALSE)`, then `wwz(..., verbose=TRUE)`. The `o=` and `v=` arguments are commented out, so decompr derives GO and VA from the matrices (L1).
- Version: none of the 7 cou scripts reads `AAMNE_VERSION`; they consume component A's `.rds` files and are version-agnostic.
- Resources (`src/0_ubuntu_example_run/example-decompr-cou-readme.md`, batch method): ~120 min per year.

### 3.C Sector-focused decomposition (cousec)

- Objective: VA contributions from (or excluding) a chosen origin-sector group, by zeroing entries of decompr's `Vc` vector before `wwz()`.
- Key files: `src_sngl/cousec/2_decompr_cousec_sngl_all.R`, `src_sngl/cousec/bash_prll/*`
- Key functions: `decompr::load_tables_vectors()`, `decompr::wwz()`, helpers `func_getvarname()`, `func_xstring()` (Section 4.6)
- Pipeline NAME: `R_aamne_decompr_cousec` in all 7 cousec scripts (own directory since R11)
- Year loop: 2000:2020 (sngl_all); batches per Section 2.8. Skip rule and message as in component B (R33).
- Sector vectors (from classification-CSV flags via `dplyr::filter(<flag>==1)`): `codes_nrrprd_vc`, `codes_nrrprd_upstrm`, `codes_nrrprd_dwnstrm`, `codes_tradables_mx`, `codes_tradables_sx`, `codes_mnfctrng_usrs`, `codes_mnfctrng_gvc`, `codes_mnfctrng_apprl`, `codes_mnfctrng_atmtv`, `codes_mnfctrng_elctrncs`, `codes_techrnd_highmed`.
- Combined vectors: `codes_tradables_umxsx = setdiff(union(mx, sx), nrrprd_vc)`; `codes_tradables_techrnd = intersect(techrnd_highmed, tradables_umxsx)`.
- Aggregates run (`vctr_sctr_aggregates`): `tradables_umxsx`, `nrrprd_upstrm`, `nrrprd_dwnstrm`, `tradables_techrnd`.
- Two runs per aggregate per year: INCLUDE (`Vc` set to 0 for names not matching the group's codes) and EXCLUDE (`Vc` set to 0 for matching names; output name prefixed `x`).
- Version: `AAMNE_VERSION` selects only the classification CSV (V18 or V23). Each year, the 6 decomposing scripts stop if the number of distinct sectors in A's industries (ownership prefix removed) differs from the CSV's row count (34 V18, 41 V23), i.e., if A ran with the other version (R27). `_end.R` reads no A files and has no such check.
- Resources (`src/0_ubuntu_example_run/example-decompr-cousec-readme.md`, batch method): ~120 min per year.

### 3.D Indexed / gross-trade transform

- Objective: reshape z, f, and production aggregates into long (indexed) tables of seller country-ownership-sector x buyer x year for gross-trade analysis; independent of `wwz()`.
- Key files: `src_sngl/1_transform_indexed_example/1_trnsfrm_indexed_sngl_all.R`, `src_sngl/1_transform_indexed_example/bash_prll/*`
- Key functions: `readr::read_csv()`, `tidyr::gather()`, `tidyr::separate()`, `dplyr::bind_rows()` (production rows), `tibble::add_column()`, `saveRDS()`
- Pipeline NAME: `R_aamne_indexed` in all 6 scripts
- Year loop: 2000:2020 (sngl_all); batches per Section 2.8.
- Processing: repeats component A's preparation logic internally (does not read A's `.rds`), including R32's label parsing; `gather`/`separate` reshape, with `extra = "merge"` on the 4 `separate()` calls whose last field is a sector; `year` added with `tibble::add_column(year = factor(i))` at all 3 `saveRDS` sites in all 6 scripts.
- Checks: 12 `stopifnot()` sites: A's 9 (R25) plus 3 `!anyNA(<table>)` checks before saving (R26).
- Classification CSV: loaded and the same sector vectors as component C are built, but no output uses them; saved tables are full, not subset. The header (lines 1-2) states this (R23).
- Version: `AAMNE_VERSION` selects both the raw-data folder and the classification CSV; the load-time dimension branch must match it (R27).
- Resources (`src/0_ubuntu_example_run/example-indexed-readme.md`, batch method): ~60 min per year. The ~20GB RAM per year figure there applies to the parallel method (excluded).

## 4. Inputs / Outputs

### 4.1 Summary

| Component | Inputs | Outputs | Format |
|---|---|---|---|
| A | `<RAW_DATA>oecd_aamne/<AAMNE_VERSION>/*<year>.csv` (raw aAMNE ICIO) | 7 files per year in `2_pipeline/R_aamne_decompr/tmp/` (4.2) | `.rds` (matrix / numeric / character vectors) |
| B | A's `tmp/` files (fixed path `2_pipeline/R_aamne_decompr/tmp/`) | `store/decomp_aamne_<year>_wwz.rds`; `out/decomp_aamne_wwz_cou.rds` under `2_pipeline/R_aamne_decompr_cou/` | `.rds` tibble |
| C | A's `tmp/` files; `<RAW_DATA>codes_sector_oecd_aamne{V18,V23}_classification.csv` | `store/decomp_aamne_<group>_<year>_wwz.rds`; 8 `out/decomp_aamne_<group>_wwz.rds` under `2_pipeline/R_aamne_decompr_cousec/` | `.rds` tibble |
| D | Raw aAMNE ICIO CSVs (as A); classification CSV (as C) | 3 files per year in `2_pipeline/R_aamne_indexed/out/` (4.5) | `.rds` tibble (factor columns) |

### 4.2 Component A outputs (per year `<i>`, in `2_pipeline/R_aamne_decompr/tmp/`)

| File | Contents |
|---|---|
| `data_aamne_countries_<i>.rds` | Country vector |
| `data_aamne_industries_<i>.rds` | Ownership_sector industry vector |
| `data_aamne_z_<i>_matrix.rds` | Intermediate demand matrix (unnamed) |
| `data_aamne_f_<i>_matrix.rds` | Final demand matrix (unnamed) |
| `data_aamne_go_<i>_vector.rds` | Gross output (GO row; final-demand columns excluded since R25) |
| `data_aamne_va_<i>_vector.rds` | Value added (GVA row) |
| `data_aamne_gva_<i>_vector.rds` | GVA + TAX (v18) or GVA + TAXSUB (v23), summed |

- V23 industries end in `D35_E36T39` since R32 (before: `D_D35`, `F_D35`). The R27 sector count is 41 either way, so cousec does not detect `tmp/` files written before R32; rerun A to refresh them.
- File names carry no aAMNE version tag; a run with another `AAMNE_VERSION` overwrites same-year files. cousec stops on a version mismatch with these files (R27); cou does not depend on the version.
- B and C load all 7 files; with `o=`/`v=` commented out, the GO, VA, and GVA vectors are not passed to decompr (L1).

### 4.3 Component B output schema

- Columns: `cntry_c` (exporting country), `sctr_s_i` (= "total"), `sctr_c_j` (exporting industry), `cntry_p` (importing country), `year` (factor), then the `wwz()` decomposition terms as returned by decompr, then `updated` (Date).
- Placement: `year` is relocated after the 3rd `wwz()` column; `sctr_s_i` is inserted before `sctr_c_j`; `updated` is appended.
- Renames applied to `wwz()` output: `Exporting_Country` -> `cntry_c`, `Exporting_Industry` -> `sctr_c_j`, `Importing_Country` -> `cntry_p`.
- Consolidation binds every `store/` file matching `decomp_aamne_[0-9]{4}_wwz.rds`, including files left by earlier runs.
- sngl_all and `_end.R` both write `2_pipeline/R_aamne_decompr_cou/out/decomp_aamne_wwz_cou.rds`.

### 4.4 Component C output schema

- `<group>` values: `tradables_umxsx`, `nrrprd_upstrm`, `nrrprd_dwnstrm`, `tradables_techrnd` (INCLUDE) and `xtradables_umxsx`, `xnrrprd_upstrm`, `xnrrprd_dwnstrm`, `xtradables_techrnd` (EXCLUDE).
- Columns: `cntry_c`, `sctr_s_i` (= `<group>`), `sctr_c_j`, `cntry_p`, `year`, then the `wwz()` terms, then `updated`; placement as in Section 4.3.
- The VA-origin label column is `sctr_s_i` in both cou and cousec (R24). Outputs consolidated before R24 carry `sctr_c_i`.
- Consolidation binds every `store/` file matching `decomp_aamne_<group>_[0-9]{4}_wwz.rds`.

### 4.5 Component D output schema (per year `<i>`, in `2_pipeline/R_aamne_indexed/out/`)

| File | Columns (in order) |
|---|---|
| `aamne_z_<i>_indxd.rds` | `cntry_s`, `ownrshp_s_i`, `sctr_s_i`, `cntry_c`, `ownrshp_c_j`, `sctr_c_j`, `year`, `int_z` |
| `aamne_fnldmnd_<i>_indxd.rds` | `cntry_s`, `ownrshp_s_i`, `sctr_s_i`, `cntry_c`, `matrix`, `matrix_compnnt`, `year`, `value` |
| `aamne_prdctn_<i>_indxd.rds` | `matrix_compnnt`, `cntry_c`, `ownrshp_c_j`, `sctr_c_j`, `year`, `value` |

- Suffix `_s` = seller, `_c` = buyer.
- `aamne_prdctn` `matrix_compnnt` values: `GO`; `VA` (aAMNE GVA row); `GVA` (GVA + TAX/TAXSUB).

### 4.6 Key function signatures

| Function | Signature as called | Location |
|---|---|---|
| `decompr::load_tables_vectors` | `(x = z_matrix, y = f_matrix, k = countries, i = industries, null_inventory = FALSE)`; `o =`, `v =` commented out | 12 decomposing cou/cousec scripts (sngl_all and 5 batches each) |
| `decompr::wwz` | `(<decompr object>, verbose = TRUE)` | same 12 scripts |
| `func_getvarname` | `function(variable, pattern_exclude = "")`: `str_remove(deparse(substitute(variable)), pattern_exclude)` | all 7 cousec scripts |
| `func_xstring` | `function(original_string, char_insert = "x")`: `paste0(char_insert, original_string)` | all 7 cousec scripts |

## 5. Known limitations

| ID | Severity | Location | Issue | Effect |
|---|---|---|---|---|
| L1 | Low (guarded, documented) | `src_sngl/1_prepdata_sngl.R` lines 457-470 (drift guard); 12 cou/cousec decomposing scripts (commented `o=`/`v=`, e.g. `src_sngl/cou/2_decompr_cou_sngl_all.R` lines 122-133); README.md "Methodological note" | aAMNE's supplied GO and GVA differ slightly from matrix-implied values (commented mean relative differences 2.296809e-06 for GO, 2.436384e-08 for VA). decompr stops with an error when supplied `o`/`v` are inconsistent (error text quoted in all 12 scripts), so `o=`/`v=` stay commented out. | decompr's GO/VA are matrix-implied, not aAMNE's published values. `1_prepdata_sngl.R` calls `warning()` per year if either difference exceeds 1e-5. Open because the inconsistency is in OECD source data. |
| L2 | Medium (metadata) | `data_urls/codes_sector_oecd_aamneV18_classification.csv`, `data_urls/codes_sector_oecd_aamneV23_classification.csv`; README.md "Sector Aggregation Logic" item 4 and "Classification-flag reference (draft)"; `src_sngl/cousec/2_decompr_cousec_sngl_all.R` line 137 | 9 flags (`mnfctrng_users`, `mnfctrng_prdcrs`, `apparel_prdcrs`, `elctrncs_prdcrs`, `autmtv_prdcrs`, `nontrdbls_cns`, `nontrdbls_sx`, `nontrdbls_scl`, `techrnd_highmed`) have only draft definitions; all 9 README rows are marked NEEDS-AUTHOR-CONFIRMATION. `techrnd_highmed` feeds the default aggregate `tradables_techrnd` (README states this since R29). | Default outputs `tradables_techrnd` and `xtradables_techrnd`, and any custom cousec or indexed aggregate built from these flags, rest on unconfirmed definitions until the author confirms them. |
| L19 | Low (documentation) | README.md "Notes for researchers", "Year coverage" bullet (line 90) | README states that every loop skips years whose raw CSV is absent from `0_data/`. cou and cousec instead skip a year when `2_pipeline/R_aamne_decompr/tmp/` has no `.rds` file whose name ends in the year (Sections 3.B, 3.C); only components A and D check for the raw CSV. README.md lies outside `src_sngl/`, where fixes for this map are applied; the `src_sngl/` side was resolved by R33. | cou/cousec coverage follows the years A has written, not the raw files present: a year with raw data but no A run is skipped, and a year whose raw CSV was removed after A ran is still decomposed from A's existing `tmp/` files. `src_sngl/` runs now say so in the log; README readers are still misled. |

- IDs L3-L17 are not reused because they appear as former IDs of resolved items (Section 6.1). L18 and L20 are resolved (R32, R34). New IDs start at L21.

## 6. Change log (history only)

### 6.1 Resolved repository items

| ID | Date | Commit | Former ID | Location | Issue | Resolution |
|---|---|---|---|---|---|---|
| R1 | 2026-07-13 | bdc5a39 | d | `src/1_transform_indexed_example/bash_prll/0_trnsfrm_indexed_sngl_btch_18-20.R` | Byte-identical copy of the 15-17 batch; looped 2015:2017 | `vctr_allyears` set to 2018:2020 |
| R2 | 2026-07-13 | bdc5a39 | e | 5 indexed batch files | Saved tables without `add_column(year=...)` used by sngl_all/prll | Year column added at all 3 `saveRDS` sites; prdctn gather/separate chain mirrored; `library(tibble)` added |
| R3 | 2026-07-13 | bdc5a39 | f | `src/cousec/bash_prll/2_decompr_cousec_sngl_btch_05-09.R` | Looped 2007:2007 | `vctr_allyears` set to 2005:2009 |
| R7 | 2026-07-13 | d666e7f | j | `src/1_prepdata_sngl.R` | Unused `library(decompr)` and unused `fnldmnd` assignment | Both removed |
| R8 | 2026-07-13 | d666e7f | L4 | README.md "Notes for researchers" | Claimed some indexed batches had narrower year ranges | Sentence rewritten to state complete 2000-2020 coverage |
| R9 | 2026-07-13 | d666e7f | L4 (config gap) | 15 classification-CSV read sites (cousec 8, indexed 7) | CSV read via hardcoded `file.path("0_data", ...)`, ignoring `AAMNE_RAW_DATA` | Replaced with `paste0(RAW_DATA, file_codes_sector)`; default behavior unchanged |
| R10 | 2026-07-15 | 51c6e6e | L4 | 7 indexed scripts | Dead `boomyears` block, with batch/non-batch year divergence | Block deleted; no `boomyears` references remain |
| R11 | 2026-07-15 | 51c6e6e | L3 | 8 cousec scripts; `3_eg_cousec_zipped.bash` | cousec shared pipeline NAME `R_aamne_decompr` with component A | NAME changed to `R_aamne_decompr_cousec`; zip script retargeted |
| R16 | 2026-09-24 | d1cbe2f | sub-defect of L1 | Both prepdata scripts; 14 cou/cousec scripts; README.md "Methodological note" | Guard message advised uncommenting `o=`/`v=` (not viable) and cited "map 7.1 L1"; `o=` comment said "gva vector" | Guard comment/message reworded (logic and threshold unchanged); "gva" corrected to "go" in 14 scripts; README sentence added on the per-year guard |
| R17 | 2026-09-24 | d1cbe2f | sub-defect of L2 | README.md "Classification-flag reference (draft)", `nontrdbls_sx` row | Listed postal services among sets absorbed from V18 `nontrdbls_cns`/`nontrdbls_scl` | Row reworded: utilities/construction from `nontrdbls_cns`, public admin/education/health from `nontrdbls_scl`, H53 from V18 `H` (`tradables_sx`); draft status unchanged |
| R21 | 2026-09-25 | 3d73730 | L8 | README.md "Dependencies" | List and install command omitted `conflicted`, `foreach`, `doParallel` | All three added to the list (`foreach`/`doParallel` marked parallel-only) and to `install.packages()` |
| R22 | 2026-09-25 | 3d73730 | L9 | Load-time dimension check in 9 scripts: prepdata x2, indexed x7 | Unmatched dimensions only printed "not ICIO-AAMNE"; failure surfaced later as an unrelated column error | `print()` replaced by `stop("not ICIO-AAMNE: ", basename(aamne_io_i), " is ", <rows>x<cols>)`; in prll scripts the error aborts the `foreach` run. Later GO/VA/GVA checks unchanged. |
| R23 | 2026-09-25 | 3d73730 | L10 | Lines 1-2 of 7 indexed scripts | Header claimed an NRR-producer subset | Header now says the scripts reshape z, final demand, and production rows into long seller x buyer x year tables; full tables; sector vectors not applied. Batches still equal `sngl_all` except the year line. |
| R24 | 2026-09-25 | 3d73730 | L11 | cousec consolidation: `2_decompr_cousec_sngl_all.R`, `2_decompr_cousec_prll.R`, `bash_prll/2_decompr_cousec_sngl_btch_end.R` (INCLUDE and EXCLUDE loops, 6 sites) | VA-origin label was `sctr_c_i` in cousec and `sctr_s_i` in cou | Renamed to `sctr_s_i`: `Vc` zeroing matches the sector suffix in every country, so the label names the VA source sector (`_s`), consistent with cou. Code reading `sctr_c_i` must be updated; files consolidated earlier keep the old name. |
| R25 | 2026-09-25 | 70b9a9c | L12 | 9 scripts (prepdata x2, indexed x7): two TEST blocks and the GO block | The five-argument `all.equal()` blocks compared only their first two arguments. The GO block kept the final-demand columns, so `aamne_go_i_vector` had z plus final-demand entries (v18 4440, v23 6776) instead of 4080 / 6314 | Names block: the 5 country and 5 industry vectors must be identical after `setdiff(., NA)`. Size block: `dim(z)`, `nrow(f)`, the GO/VA/GVA lengths, and countries x industries must be equal. The GO block drops final-demand columns (`select(!contains("fnldmnd"))`, the z-block idiom), so the saved GO vector and A's drift guard (L1) use one entry per country-industry. Indexed outputs are unchanged (prdctn already dropped these columns). GO `.rds` files written before R25 keep the old length until A is rerun. |
| R26 | 2026-09-25 | 70b9a9c | L13 | 7 indexed scripts, 3 sites each | No-NA check passed when at least one column was NA-free | Replaced with `!anyNA(<table>)`, which checks every column of a data frame or tibble; a table with NA in any column now stops the year |
| R27 | 2026-09-25 | 70b9a9c | L14 | Load-time branch in 9 scripts (prepdata x2, indexed x7); 7 cousec decomposing scripts; README.md "Notes for researchers" | Table shape was never compared with `AAMNE_VERSION`; cousec did not check A's untagged `tmp/` files against its CSV; README claimed auto-verification | Each load-time branch also requires `aamne_version == "aamne18"` / `"aamne23"`, and the `stop()` message names the version. cousec stops per year unless the number of distinct sectors in `industries_aamne` (`sub("^[A-Z]_", "", ...)`) equals the CSV's row count (34 V18, 41 V23). A count is used rather than code matching because V23 code `D35_E36T39` contains `_`, the separator A's label parsing splits on. README bullet describes both checks. A's file names still carry no version tag. |
| R29 | 2026-09-25 | 70b9a9c | sub-defect of L2 | README.md "Classification-flag reference (draft)", closing paragraph | List of flags used by the default aggregates omitted `techrnd_highmed` | Paragraph lists it and states that `tradables_techrnd` / `xtradables_techrnd` share its draft status; draft definitions unchanged, so L2 stays open |
| R30 | 2026-09-25 | 6a51095 | L16 | `data_urls/codes_sector_oecd_aamneV23_classification.csv` column `sector_aggrgt_name_prdcrs`; `data_urls/codes_sector_oecd_aamneV18_classification.csv` row `B` | V23 producer labels at C23, C24, C25, C26, C28, C29, C31T33, D35_E36T39, F41T43 held the V18 label of the next row's sector; T97T98 was blank; V18 row B `sector_disaggrgt_name` was the placeholder `nrr_upstrm` | The 10 V23 cells now hold the V18 label of the same sector (D35_E36T39 from DTE, F41T43 from F, T97T98 from T); all 41 V23 producer labels equal V18's for the corresponding sector. V18 row B renamed "Mining and quarrying" (ISIC Rev.4 section B). Only these 11 cells changed: sector codes, flags, shapes (34x18, 41x16), and the missing trailing newline are unchanged, so pipeline outputs are unaffected |
| R31 | 2026-09-25 | 6a51095 | L17 | `.gitignore` | No entries for `0_data/`, `2_pipeline/`, `3_output/`; raw aAMNE CSVs and pipeline `.rds` outputs showed as untracked, and `git add -A` staged them | Root-anchored `/0_data/`, `/2_pipeline/`, `/3_output/` appended under a comment citing README "Folder structure and data". Root anchoring matches README "Usage" (folders at the clone root); `data_urls/` stays tracked, and no tracked file lies under the new paths |
| R32 | 2026-11-05 | a3144fc | L18 | `src_sngl/1_prepdata_sngl.R` lines 107, 164, 279, 328, 383; 6 indexed scripts, lines 186, 243, 260, 262, 332, 381, 435, 494, 598 | V23 code `D35_E36T39` contains `_`: A's v23 label split dropped `E36T39` (tidyr: "Additional pieces discarded in 154 rows"), so A labeled the sector `D_D35`/`F_D35`, cousec's `(<code>)$` filter never matched it, and indexed `separate()` wrote `D35` | `extra = "merge"` on the v23 label split (A and D) and on the 4 indexed `separate()` calls whose last field is a sector; industry regex `[0-9A-Z]+` widened to `[0-9A-Z_]+` at its 4 sites per script; indexed line 334 (final-demand components) unchanged. Synthetic V23 table at 6317x6777: z, f, GO, VA, GVA identical before and after; only the 2 labels change; a `nontrdbls_sx` cousec filter matches 1694/1694 `Vc` names (was 1540); default aggregates unchanged. Rerun A to refresh older V23 `tmp/` files (Section 4.2) |
| R33 | 2026-11-05 | a3144fc | L19 (src_sngl side) | 12 cou/cousec decomposing scripts in `src_sngl/` (cou line 77, cousec line 171 in `sngl_all`; same line in the batches) | Skip message `Data unavailable for year <i>` did not say that cou/cousec check A's `tmp/` folder, not the raw CSV that README.md describes | Message now ends `: no data-prep output in 2_pipeline/R_aamne_decompr/tmp/`; skip logic unchanged. README.md (outside `src_sngl/`) unchanged, so L19 stays open for it |
| R34 | 2026-11-05 | a3144fc | L20 | `src_sngl/cou/bash_prll/2_decompr_cou_sngl_btch_end.R`; 5 cousec batches and `src_sngl/cousec/bash_prll/2_decompr_cousec_sngl_btch_end.R` (lines 21-22) | Commented-out `# library(foreach)` / `# library(doParallel)` remained in the single-core subset | Both lines deleted in the 7 scripts; no `foreach`/`doParallel` text remains in `src_sngl/` |

- R1-R31 (except those omitted below) are inherited from the parent map; R32-R34 were made in `src_sngl/` only. Inherited locations name the `src/` originals as fixed at the time; the `src_sngl/` copies carry every fix.
- Omitted because they touch only files excluded from `src_sngl/` (Section 2.7): R4, R5, R6, R12, R13, R14, R15, R18, R19, R20, R28. Their IDs are not reused.
- Commit for each item is the latest commit whose diff contains the fixed text (`git log -S`/`-G`).

### 6.2 Map revisions

- M1-M12 are revisions of the parent map; their section numbers refer to the parent map's layout (e.g. its 2.7 Ubuntu files, 7.2 system tools).


| ID | Date | HEAD | Change |
|---|---|---|---|
| M1 | 2026-09-24 | d885b1f | Re-verified loops, NAMEs, clusters, skip logic, CSV read sites and shapes, dispatchers, consolidators, zip targets, dependencies, drift guard, stopifnot counts, cousec aggregates, indexed schema; recorded R14 and R15 |
| M2 | 2026-09-24 | d885b1f | Added missing Section 2 row for `cou/1_ubuntu_eg_decompr_cou_prll.bash` |
| M3 | 2026-09-24 | d885b1f | Advanced HEAD citation from 4f2af12 to d885b1f; replaced space-padded pseudo-tables with Markdown tables |
| M4 | 2026-09-24 | d885b1f | Converted limitations to the ID/Severity/Location/Issue/Effect table |
| M5 | 2026-09-24 | d885b1f (uncommitted edits) | Recorded R16 and R17 |
| M6 | 2026-09-24 | d1cbe2f | HEAD advanced to d1cbe2f and R16/R17 marked committed; sections reordered to Purpose, Structure, Components, Inputs/Outputs, Limitations, Change log, Other aspects; banners, escapes, and prose blocks replaced by headings, tables, and bullets; change log converted to a table with commits for R1-R9; corrections: `warn()` to `warning()`, batch naming note, `.DS_Store` status, `parallel_example.R` description, setup-data gsutil step; added output schemas, function signatures, URL-file details, system tools; added L5-L11 |
| M7 | 2026-09-25 | d1cbe2f (uncommitted edits) | Recorded R18-R24 (former L5-L11) and removed them from Section 5; updated Sections 0, 2.7, 3.A, 3.D, 3.E, 4.4, 4.6, 7.1, 7.2, 7.5, 7.6 |
| M8 | 2026-09-25 | 3d73730 | HEAD advanced to 3d73730 and R18-R24 marked committed; removed absent `.DS_Store` row; flag values corrected to 1/blank; added Key functions (A, D, E), Resources (A, B, C), Checks (A, D), and Version (C, D) fields, and aligned field order across Section 3; named the drift-guard comparands and listed the 4 unreachable `print()` sites; added indexed-wrapper `chmod`/stale-log details, the walkthrough platform, and a launch-privilege note; clarified the stringr/tibble rows; added a source for the Section 1 use case; added version notes to 4.2 and 7.5; L2 extended to `tradables_techrnd`; added L12-L15 |
| M9 | 2026-09-25 | 3d73730 (uncommitted edits) | Recorded R25-R29 (former L12-L15 and an L2 sub-defect) and removed L12-L15 from Section 5; updated Sections 0, 2.7, 3.A, 3.C, 3.D, 3.E, 4.2, 5 (L2 row, ID note), 7.5 |
| M10 | 2026-09-25 | 70b9a9c | HEAD advanced to 70b9a9c and R25-R29 marked committed; added L16 (V23 producer-label misalignment, V18 row B name) with a Section 2.2 pointer and L17 (`.gitignore` omits data and pipeline folders) with a Section 2.1 note; stated the B/C year-skip rule in Sections 3.B and 3.C; listed wget users in Section 7.2 |
| M11 | 2026-09-25 | 70b9a9c (uncommitted edits) | Recorded R30-R31 (former L16, L17) and removed them from Section 5; updated Sections 0, 2.1, 2.2, 5 (ID note). L1 (OECD source data) and L2 (awaiting author confirmation; author chose to keep it open) remain open |
| M12 | 2026-09-25 | 6a51095 | HEAD advanced to 6a51095 and R30-R31 marked committed; README row in Section 2.1 lists all 11 README sections; Section 2.5 batch note adds the `# END of loop` comment difference; Section 2.7 `_sngl_2` rows add log path and stale-log `rm` location; added L18 (V23 code `D35_E36T39` unmatchable by cousec and indexed sector labels) and L19 (README year-skip rule differs from cou/cousec code); Section 5 ID note advanced to L20. Re-verified by script: dependency and config counts (7.1, 7.5), loops and NAMEs (2.8, 7.5), clusters, `stopifnot` counts, function signatures (4.7), CSV shapes and flags (2.2), URL files, 56/56 tracked files named in Section 2 |
| M13 | 2026-11-05 | 6a51095 (uncommitted `src_sngl/`) | Derived this map from the parent for `src_sngl/`: scope and metadata (Section 0); Section 2 lists the 21 copied scripts and the excluded `src/` files; parallel settings, component E, its outputs, the system-tools table, and the parallel-cluster table removed; counts re-derived for `src_sngl/` (7 cou, 7 cousec, 6 indexed, 12 decomposing scripts); L1, L2, L18, L19 locations re-pointed to `src_sngl/`; 6.1 keeps the 20 items that touch `src_sngl/` or repository-root files |
| M14 | 2026-11-05 | 6a51095 + `src_sngl/` (PR mmvvff/aamne_decompr#3) | Applied evaluation items E1-E7 (Section 6.3); added L20; Section 5 ID note advanced to L21. Re-verified by script: 21/21 copies byte-identical to `src/`, batch-vs-`sngl_all` differences, CSV shapes, flags, suffixes and `_` codes, URL counts, `stopifnot`/`stop()` sites, `func_*` and decompr call sites, `year` columns, `AAMNE_VERSION`/`AAMNE_RAW_DATA` readers; no cosmetic indentation or prose-only blocks found |
| M15 | 2026-11-05 | a3144fc | Recorded R32-R34 (former L18, L19 src_sngl side, L20) and removed L18, L20 from Section 5; L19 narrowed to README.md; updated Sections 0, 2.2, 2.3, 2.6, 3.A-3.D, 4.2, 7.1, 7.6 |

### 6.3 Map evaluation items (applied in M14)

| ID | Section | Finding | Evidence (file path) | Required change |
|---|---|---|---|---|
| E1 | 0 | "Derived from" named `aamne_decompr-map.md` as if it were a repository file | `git ls-files` (56 tracked files; no map file) | State that the parent map is supplied outside the repository |
| E2 | 6.2 | M1-M12 cite parent-map section numbers that differ here (parent 2.7 = Ubuntu files, 7.2 = system tools) | `src_sngl/aamne_decompr-map-sngl.md` Sections 2.7, 7.2 | Add a note that M1-M12 refer to the parent map's layout |
| E3 | 5 (L18) | Location omitted the industry regex at prepdata lines 279, 328, 383 and indexed lines 243, 381, 435, 494, the indexed v23 label parsing (lines 183-186), and the indexed final-demand `separate()` (line 332) | `src_sngl/1_prepdata_sngl.R`; `src_sngl/1_transform_indexed_example/1_trnsfrm_indexed_sngl_all.R` | List every site |
| E4 | 5, 7.1 | Commented-out `# library(foreach)` / `# library(doParallel)` in 7 scripts were noted only as a dependency fact | `src_sngl/cou/bash_prll/2_decompr_cou_sngl_btch_end.R` lines 21-22; `src_sngl/cousec/bash_prll/*.R` lines 21-22 | Add as limitation L20 |
| E5 | 5 (L19) | L19 described only the README side; in `src_sngl/` the cou/cousec skip message does not name the folder it checks | `src_sngl/cou/2_decompr_cou_sngl_all.R` line 77; `src_sngl/cousec/2_decompr_cousec_sngl_all.R` line 171 | Add the message to L19's Location and Issue |
| E6 | 0 | Scope listed walkthroughs, which are not in `src_sngl/` | `src/0_ubuntu_example_run/example-*-readme.md` (cited in Sections 3.B-3.D) | Say they are cited for runtimes only |
| E7 | 2.6 | Batch note did not state how cousec batches differ from `sngl_all` (2.4 and 2.5 do) | `src_sngl/cousec/2_decompr_cousec_sngl_all.R` vs `src_sngl/cousec/bash_prll/2_decompr_cousec_sngl_btch_00-04.R` | List the differences |

## 7. Other relevant aspects

### 7.1 R dependencies

| Package | How loaded | Where |
|---|---|---|
| readr, tidyr, dplyr | `library()` | all 21 scripts |
| stringr | `library()` in 20 scripts; `1_prepdata_sngl.R` calls it only as `stringr::` | all 21 scripts |
| decompr | `library()` | 14 cou/cousec scripts; the 2 `_end.R` call no decompr function |
| conflicted | `library()` (no `conflict_prefer` calls) | all 21 scripts |
| tibble | `library()` in the 6 indexed scripts; the other 15 call it only as `tibble::` | all 21 scripts |
| foreach, doParallel | not used (commented-out lines removed by R34) | none |

- Install: `install.packages(c("readr", "tidyr", "dplyr", "stringr", "tibble", "decompr", "conflicted"))`. README.md "Dependencies" also lists `foreach` and `doParallel`, marked parallel-only (R21); `src_sngl/` does not need them.
- The repository itself is not installed; scripts are sourced directly.

### 7.2 Runtime

- R only. `src_sngl/` contains no bash scripts and needs no system tools; the Ubuntu tools (wget, aria2, unzip, pigz, gsutil) belong to the excluded `src/0_ubuntu_example_run/` (Section 2.7).

### 7.3 License

- Code: MIT License, Copyright (c) 2024 Manuel Valderrama-Florez (`LICENSE`). Covers repository code only.

### 7.4 Data sources

- OECD Analytical AMNE (aAMNE), versions 2018 and 2023; 2023 release updated May 2024 (README.md "Folder structure and data").
- Raw data is not redistributed; OECD access and usage terms apply.
- URL lists exist for aAMNE23 only (`data_urls/url_aamne23.txt`, `.tsv`); v18 data must be obtained manually.
- Sector classification CSVs for v18 and v23 are in `data_urls/` (Section 2.2).

### 7.5 Configuration

| Variable | Meaning | Default | Read by |
|---|---|---|---|
| `AAMNE_PROJECT_DIR` | Project root directory | `.` | all 21 scripts |
| `AAMNE_PROJECT` | Project subfolder under the root | `""` | all 21 scripts |
| `AAMNE_RAW_DATA` | Relative raw-data path, with trailing slash; covers raw CSVs and the classification CSV | `0_data/` | read by all 21; used by prepdata, cousec x7, indexed x6 |
| `AAMNE_VERSION` | `aamne18` or `aamne23`; selects raw-data folder (prepdata, indexed) and classification CSV (cousec, indexed); the raw table's shape must match it (prepdata, indexed), and cousec checks A's files against its CSV (R27) | `aamne23` | 14 scripts: prepdata, cousec x7, indexed x6 (not cou x7) |

- Project root: `normalizePath(file.path(AAMNE_PROJECT_DIR, AAMNE_PROJECT))`, then `setwd()`.
- Pipeline folders: each script creates `2_pipeline/<NAME>/` plus `out/`, `store/`, `tmp/` only when `2_pipeline/<NAME>/` is absent; `dir.create()` is non-recursive, so `2_pipeline/` must already exist (README.md "Folder structure and data").

| Component | Pipeline NAME | Subfolders used |
|---|---|---|
| A (data prep) | `R_aamne_decompr` | `tmp/` |
| B (cou) | `R_aamne_decompr_cou` | `store/`, `out/` |
| C (cousec) | `R_aamne_decompr_cousec` | `store/`, `out/` |
| D (indexed) | `R_aamne_indexed` | `out/` |

### 7.6 Usage flow (local, from the clone root)

1. Clone the repository; create `0_data/`, `2_pipeline/`, `3_output/`; place aAMNE data under `0_data/oecd_aamne/aamne18/` or `0_data/oecd_aamne/aamne23/`; copy the matching classification CSV from `data_urls/` into `0_data/` (needed by cousec and indexed). Source: README.md "Usage" steps 1-2.
2. Optionally set `AAMNE_PROJECT_DIR`, `AAMNE_PROJECT`, `AAMNE_RAW_DATA`, `AAMNE_VERSION` (Section 7.5).
3. Run data prep: `Rscript -e 'source("src_sngl/1_prepdata_sngl.R")'`.
4. Run a decomposition, either in one script (`src_sngl/cou/2_decompr_cou_sngl_all.R` or `src_sngl/cousec/2_decompr_cousec_sngl_all.R`) or as the 5 batch files of `bash_prll/` one after another followed by that folder's `_end.R`. The indexed transform (`src_sngl/1_transform_indexed_example/`, `sngl_all` or its 5 batches) is independent of step 3 and has no `_end.R`.
5. Read results from `2_pipeline/<NAME>/out/` (Section 4).

- The README.md single-core command (`source("src/1_prepdata_sngl.R"); source("src/cou/2_decompr_cou_sngl_all.R")`) runs the `src/` originals, which lack R32-R34.

### 7.7 Citations requested (README.md "Citation")

- Miroudot, S. & Ye, M. (2019). "Multinational production in value-added terms". Economic Systems Research.
- Quast, B.A. & Kummritz, V. (2015). "decompr: Global Value Chain decomposition in R". CTEI Working Papers, 1.
- Wang, Z., Wei, S.-J. & Zhu, K. (2013). "Quantifying international production sharing at the bilateral and sector levels". NBER Working Paper w19677.
