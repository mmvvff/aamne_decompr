# OECD Analytical AMNE Value-Added Decomposition

This repository implements the value-added trade accounting framework of Wang et al. (2013) using data from the OECD's Analytical AMNE database. The decomposition is performed using the `decompr` R package, and various strategies are outlined to identify value-added trade within sector-to-sector relationships.

## Overview

The main objective of this project is to:

1. Prepare data from the OECD's [Analytical AMNE](https://www.oecd.org/en/data/datasets/multinational-enterprises-and-global-value-chains.html) (Activities of Multinational Enterprises) database.
2. Apply the value-added trade accounting framework developed by Wang et al. (2013).
3. Utilize the `decompr` R package to perform the decomposition.
4. Delineate a strategy to estimate VA-trade content for specific sector-sector relations in the context of `decompr`.

This tool allows researchers and analysts to gain insights into global value chains and the contribution of multinational enterprises to international trade at specific sector-sector relations.

## Dependencies

This project requires R and the following R packages:

- `decompr`
- `dplyr`
- `readr`
- `tidyr`

You can install these packages using:

```R
install.packages(c("decompr", "dplyr", "readr", "tidyr"))
```

## Data

The data used in this project comes from the OECD's Analytical AMNE database. You will need to download this data separately and place it in the `data/` directory. Please refer to the OECD website for access and usage terms.

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/oecd-amne-decomposition.git
   cd oecd-amne-decomposition
   ```

2. Place the OECD Analytical AMNE data in the `data/` directory.

3. Run the main script:
   ```
   Rscript src/main.R
   ```

4. The results will be saved in the `output/` directory.

## Structure

The repository is structured as follows:

```
.
├── data/           # Raw data files (not included in repo)
├── src/            # Source code
│   ├── main.R      # Main script
│   └── utils.R     # Utility functions
├── output/         # Output files
├── README.md       # This file
└── LICENSE         # License file
```

## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes.

## Citation

If you use this tool in your research, please cite both this repository, the original Wang et al. (2013) paper and the `decompr` package:

Wang, Z., Wei, S. J., & Zhu, K. (2013). Quantifying international production sharing at the bilateral and sector levels ([No. w19677](https://www.nber.org/papers/w19677)). National Bureau of Economic Research.

Quast, B.A. and V. Kummritz (2015). decompr: Global Value Chain decomposition in R. [CTEI Working Papers, 1](https://repec.graduateinstitute.ch/pdfs/cteiwp/CTEI-2015-01.pdf). [R link](https://cran.r-project.org/web/packages/decompr/index.html)

## License

This project is licensed under the MIT License - see the LICENSE file for details.