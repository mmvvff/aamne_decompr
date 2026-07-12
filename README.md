# WWZ Value-Added Decomposition of the OECD's Analytical AMNE

This repository implements the value-added trade accounting framework of Wang et al. (2013) using data from the OECD's [Analytical AMNE](https://doi.org/10.1787/d9de288d-en) (Activities of Multinational Enterprises) database. The decomposition is performed using the `decompr` R package, and strategies are outlined to estimate value-added trade within sector-to-sector relationships.

## Overview

The main objectives of this project are to:

1. Prepare data from the OECD's Analytical AMNE [database](https://www.oecd.org/en/data/datasets/multinational-enterprises-and-global-value-chains.html), following the strategy delineated in Miroudot & Ye (2019: 14).
2. Apply the value-added trade accounting framework developed by Wang et al. (2013), using the `decompr` R package to perform the decomposition.
3. Delineate a strategy to estimate VA-trade content for specific sector-sector relations in the context of `decompr`.

This tool allows researchers and analysts to gain insights into global value chains and the contribution of multinational enterprises to international trade at specific sector-sector relations.

## Dependencies

This project requires R and the following R packages:

- `readr`
- `tidyr`
- `dplyr`
- `stringr`
- `decompr`

You can install these packages using:

```R
install.packages(c("decompr", "dplyr", "readr", "tidyr", "stringr"))
```

## Folder structure and data

You need to setup in your local machine the following folder structure:

```
.
├── 0_data/                 # Raw data files
├── 2_pipeline/             # Data processing pipelines
├── 3_output/               # Output files
```

If you prefer not to use your local machine, you may also explore setting up an [R-server in Linux](https://github.com/mmvvff/r_ubuntu).

The above folder structure draws on [Ties de Kok's suggestions](https://towardsdatascience.com/how-to-keep-your-research-projects-organized-part-1-folder-structure-10bd56034d3a). The first lines of code in all scripts include these suggestions to facilitate the creation of subfolders.

The data used in this project comes from the OECD's Analytical AMNE [database](https://www.oecd.org/en/data/datasets/multinational-enterprises-and-global-value-chains.html). You will need to download this data separately and place it in the `0_data/` directory. Please refer to the OECD website for access and usage terms. For convenience, a [TSV file](data_urls) has been prepared with a list of static URLs for the latest aAMNE 2023 release (updated May 2024).

The scripts in this project can handle both the 2018 and 2023 versions of aAMNE.
The choice between versions depends on the researcher's judgment and specific research needs.

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/mmvvff/aamne_decompr.git
   cd aamne_decompr
   ```

2. Place the OECD Analytical AMNE data in the `0_data/` directory (under `0_data/oecd_aamne/aamne18/` or `0_data/oecd_aamne/aamne23/`). Copy the sector classification CSV from [`data_urls/`](data_urls) into `0_data/` (e.g., `codes_sector_oecd_aamneV23_classification.csv`); the `cousec` and indexed-transform scripts read it from there.

   The scripts are configured through environment variables, with sensible defaults: `AAMNE_PROJECT_DIR` (defaults to `.`, the current working directory), `AAMNE_PROJECT` (defaults to empty string), `AAMNE_RAW_DATA` (defaults to `0_data/`), and `AAMNE_VERSION` (defaults to `aamne23`). Set these to customize your setup, e.g.:
   ```
   export AAMNE_PROJECT_DIR="$HOME/projects"
   export AAMNE_VERSION="aamne18"
   ```

3. There are two main subsets of R scripts: single core and parallel processing. I strongly suggest to use the latter for faster processing times.

   For single core processing:
   ```
   Rscript -e 'source("src/1_prepdata_sngl.R"); source("src/cou/2_decompr_cou_sngl_all.R")'
   ```
   For parallel processing:
   ```
   Rscript -e 'source("src/1_prepdata_prll.R"); source("src/cou/2_decompr_cou_prll.R")'
   ```

4. There are two additional subsets of scripts addressing different analytical concerns:

   - If you are interested in revealing the VA content via backward linkages with the entire economy, choose this [subset of scripts](https://github.com/mmvvff/aamne_decompr/tree/main/src/cou). These scripts help reveal the aggregate VA contributions from all sectors of origin (sources of VA) to each of the sectors of destination (users of VA) covered in the aAMNE database. This is the typical approach of `decompr`. Please look at the [example provided](src/0_ubuntu_example_run/example-decompr-cou-readme.md).

   - Alternatively, if you are interested in revealing the VA content via backward linkages with a special focus on certain sectors (e.g., only tradable sectors), choose this [subset of scripts](https://github.com/mmvvff/aamne_decompr/tree/main/src/cousec). These scripts help reveal the VA contributions from a specific sector of origin (source of VA) to each of the sectors of destination (users of VA) covered in the aAMNE database. To accomplish this, these scripts modify the inputs feeding into `decompr`. Please look closely at the [example provided](src/0_ubuntu_example_run/example-decompr-cousec-readme.md).

5. The main results are saved under `2_pipeline/<NAME>/out/`, where `<NAME>` is the pipeline name set in each script (e.g., `2_pipeline/R_aamne_decompr_cou/out/` for the country-level decomposition).

## Methodological note

Both decomposition components (`cou` and `cousec`) let `decompr` estimate gross output (`o`) and value added (`v`) from the supplied intermediate- and final-demand matrices, rather than passing aAMNE's own `GO` and `GVA` vectors. This is deliberate: aAMNE's supplied aggregates differ slightly from the values implied by the matrices (mean relative differences on the order of 2e-06 for output and 2e-08 for value added), which would otherwise fail `decompr`'s internal consistency checks. The rationale is documented inline in the decomposition scripts.

## Structure

The repository is structured as follows:

```
.
├── src/                    # Source code
│   ├── cou/
│   │   ├── 2_decompr_cou_sngl_all.R
│   │   └── ...
│   ├── cousec/
│   ├── 1_transform_indexed_example/
│   ├── 0_ubuntu_example_run/
│   ├── 1_prepdata_sngl.R
│   └── ...
├── data_urls/              # Data URLs and sector classification CSVs
├── README.md               # This file
└── LICENSE                 # License file
```


## Contributing

Contributions to this project are welcome, but keep in mind that this is **a work in progress**. For example, there is some data not fully explained that is used to aggregate sectors for my own research purposes.

Please fork the repository and submit a pull request with your changes.

## Citation

If you use this tool in your research, please cite both this repository and the following references:

Miroudot, Sébastien & Ye, Ming (2019). "Multinational production in value-added terms". [Economic Systems Research, Online version](https://doi.org/10.1080/09535314.2019.1701997)

Quast, B.A. and V. Kummritz (2015). "decompr: Global Value Chain decomposition in R". [CTEI Working Papers, 1](https://repec.graduateinstitute.ch/pdfs/cteiwp/CTEI-2015-01.pdf). For the R project, [follow this link](https://cran.r-project.org/web/packages/decompr/index.html)

Wang, Z., Wei, S. J., & Zhu, K. (2013). "Quantifying international production sharing at the bilateral and sector levels" ([No. w19677](https://www.nber.org/papers/w19677)). National Bureau of Economic Research.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
