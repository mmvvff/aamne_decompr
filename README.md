# OECD Analytical AMNE WWZ Value-Added Decomposition

This repository implements the value-added trade accounting framework of Wang et al. (2013) using data from the OECD's [Analytical AMNE database](https://doi.org/10.1787/d9de288d-en). The decomposition is performed using the `decompr` R package, and some strategies are outlined to estimate value-added trade within sector-to-sector relationships.

## Overview

The main objective of this project is to:

1. Prepare data from the OECD's [Analytical AMNE](https://www.oecd.org/en/data/datasets/multinational-enterprises-and-global-value-chains.html) (Activities of Multinational Enterprises) database, following the strategy delineated in [Miroudot & Ye (2019: 14)](https://doi.org/10.1080/09535314.2019.1701997)
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

## Data

The data used in this project comes from the OECD's Analytical AMNE database. You will need to download this data separately and place it in the `data/` directory. Please refer to the OECD website for access and usage terms.

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/mmvvff/aamne_decompr.git
   cd aamne_decompr
   ```

2. Place the OECD Analytical AMNE data in the `1_data/` directory.

3. There are two main subsets of R scripts; single core and parallel processing.

For single core processing:
   ```
   Rscript -e 'source("src/1_prepdata_sngl.R"); source("src/cou/1_decompr_sngl.R")'
   ```
For parallel processing:
  ```
  Rscript -e 'source("src/1_prepdata_prll.R"); source("src/cou/1_decompr_cou_prll.R")'
  ```

4. In turn, there are two additional subset of scripts addressing different analytical concerns:

- If you are interested in revealing the VA content via backward linkages
with the entire economy, choose this subset of scripts. This scripts help reveal
the aggregate VA contributions from all sectors of origin (sources of VA)
to each of the sectors of destination covered in the aAMNE database (users of VA).
This is the typical approach of `decompr`.

- If you are interested in revealing the VA content via backward linkages
with special focus on certain sectors (e.g., only tradable sectors),
choose this subset of scripts. This reveals the aggregate VA contributions
from a specific sector of origin (source of VA) to each of
the sectors of destination covered in the aAMNE database (users of VA).
These scripts modify the inputs feeding into `decompr`.
Please look closely at the example provided

5. The results will be saved in the `output/` directory.

## Structure

The repository is structured as follows:

```
.
├── 1_data/                 # Raw data files (not included in repo)
├── 2_pipeline/             # data processing pipelines
├── 3_output/               # Output files
├── src/                    # Source code
│   ├── cou/
│      ├── 1_decompr_sngl.R # script
│      └── ...    
│    ├── 1_prepdata_sngl.R
│    └── ...  
├── README.md               # This file
└── LICENSE                 # License file
```

The above folder structure draws on [Ties de Kok suggestions](https://towardsdatascience.com/how-to-keep-your-research-projects-organized-part-1-folder-structure-10bd56034d3a). The first lines of code in all scripts include these suggestions to facilitate the creation of subfolders.

## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes.

## Citation

If you use this tool in your research, please cite both this repository, the original Wang et al. (2013) and Miroudot & Ye (2019) papers, and the `decompr` package:

Miroudot, Sébastien & Ye, Ming (2019). "Multinational production in value-added terms". [Economic Systems Research, Online version](https://www.tandfonline.com/doi/full/10.1080/09535314.2019.1701997)

Wang, Z., Wei, S. J., & Zhu, K. (2013). "Quantifying international production sharing at the bilateral and sector levels" ([No. w19677](https://www.nber.org/papers/w19677)). National Bureau of Economic Research.

Quast, B.A. and V. Kummritz (2015). "decompr: Global Value Chain decomposition in R". [CTEI Working Papers, 1](https://repec.graduateinstitute.ch/pdfs/cteiwp/CTEI-2015-01.pdf). [R link](https://cran.r-project.org/web/packages/decompr/index.html)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
