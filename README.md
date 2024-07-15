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
├── 1_data/                 # Raw data files
├── 2_pipeline/             # Data processing pipelines
├── 3_output/               # Output files
```

If you prefer not to use your local machine, you may also explore setting up an [R-server in Linux](https://github.com/mmvvff/r_ubuntu).

The above folder structure draws on [Ties de Kok's suggestions](https://towardsdatascience.com/how-to-keep-your-research-projects-organized-part-1-folder-structure-10bd56034d3a). The first lines of code in all scripts include these suggestions to facilitate the creation of subfolders.

The data used in this project comes from the OECD's Analytical AMNE [database](https://www.oecd.org/en/data/datasets/multinational-enterprises-and-global-value-chains.html). You will need to download this data separately and place it in the `1_data/` directory. Please refer to the OECD website for access and usage terms. For convenience, a [TSV file](https://github.com/mmvvff/aamne_decompr/tree/main/data_urls) has been prepared with a list of URLs for the latest aAMNE 2023 release.

The scripts in this project can handle both the 2018 and 2023 versions of aAMNE.
The choice between versions depends on the researcher's judgment and specific research needs.

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/mmvvff/aamne_decompr.git
   cd aamne_decompr
   ```

2. Place the OECD Analytical AMNE data in the `1_data/` directory.

3. There are two main subsets of R scripts: single core and parallel processing. I strongly suggest to use the latter for faster processing times.

   For single core processing:
   ```
   Rscript -e 'source("src/1_prepdata_sngl.R"); source("src/cou/1_decompr_sngl.R")'
   ```
   For parallel processing:
   ```
   Rscript -e 'source("src/1_prepdata_prll.R"); source("src/cou/1_decompr_cou_prll.R")'
   ```

4. There are two additional subsets of scripts addressing different analytical concerns:

   - If you are interested in revealing the VA content via backward linkages with the entire economy, choose this [subset of scripts](https://github.com/mmvvff/aamne_decompr/tree/main/src/cou). These scripts help reveal the aggregate VA contributions from all sectors of origin (sources of VA) to each of the sectors of destination (users of VA) covered in the aAMNE database. This is the typical approach of `decompr`.

   - If you are interested in revealing the VA content via backward linkages with a special focus on certain sectors (e.g., only tradable sectors), choose this [subset of scripts](https://github.com/mmvvff/aamne_decompr/tree/main/src/cousec). This reveals the VA contributions from a specific sector of origin (source of VA) to each of the sectors of destination (users of VA) covered in the aAMNE database. To accomplish this, these scripts modify the inputs feeding into `decompr`. Please look closely at the example provided.

5. The results will be saved in the `output/` directory.

## Structure

The repository is structured as follows:

```
.
├── src/                    # Source code
│   ├── cou/
│   │   ├── 1_decompr_sngl.R # Script
│   │   └── ...    
│   ├── 1_prepdata_sngl.R
│   └── ...  
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
