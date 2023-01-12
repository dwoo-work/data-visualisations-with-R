# Data Visualisations with R

This will demonstrate to you how to perform basic data visualisations techniques, using R-programming and ggplot.

The purpose of this is to analyse sales data with the use of visualisation tools, to help gain more insights on the data.

## Installation

Download and install these packages from [official CRAN repository](https://cran.r-project.org/):

- readr: to read data from .csv or .xlsx files.
- dplyr: to provide a set of functions for data manipulation.
- DT: to allow you to work with large datasets.
- ggplot2: to create a wide variety of plots and charts.

```bash
install.packages(c("readr", "dplyr", "DT", "ggplot2"))
```

## Sample Dataset

For this, you can download the sales_data_sample_utf8.csv file from the source folder, which is located [here](https://github.com/dwoo-work/time-series-forecasting/tree/main/src).

Ensure that the file is in CSV UTF-8 format, to avoid UnicodeDecodeError later on.

## Code Explanation

Lines 1-12:  
Load all of the libraries in a single line of code.
```r  
required_libraries <- c("readr", "dplyr", "DT", "ggplot2")
lapply(required_libraries, require, character.only = TRUE)
```

## Credit

Sales Data Sample (https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)

## License

[MIT](https://choosealicense.com/licenses/mit/)
