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

Lines 6-7:  
This code ensures that all the necessary libraries are loaded and available for use in the project.
```r  
required_libraries <- c("readr", "dplyr", "DT", "ggplot2")
lapply(required_libraries, require, character.only = TRUE)
```

Lines 9-10:  
This code is used to import and inspect the data from the sales file.
```r  
sales <- read_csv("sales_data_sample_utf8.csv")
glimpse(sales)
```

Line 12:  
This code is used to find unique values of each column of the sales dataframe, which helps to understand the variables and the data.
```r  
unique_values <- apply(sales, 2, unique)
```

Lines 18-40:  
Create two variables, which identifies the number of product codes, and the average deal size for each product line.
```r  
sales <- sales %>%
  mutate(product_line = case_when(PRODUCTLINE == "Motorcycles" ~ "Motorcycles",
                                  PRODUCTLINE == "Classic Cars" ~ "Classic Cars",
                                  PRODUCTLINE == "Trucks and Buses" ~ "Trucks and Buses",
                                  PRODUCTLINE == "Vintage Cars" ~ "Vintage Cars",
                                  PRODUCTLINE == "Planes" ~ "Planes",
                                  PRODUCTLINE == "Ships" ~ "Ships",
                                  PRODUCTLINE == "Trains" ~ "Trains")) %>%
  group_by(product_line) %>%
  mutate(no_of_product_codes = n_distinct(PRODUCTCODE)) %>%
  left_join(
    sales %>%
      mutate(product_line = case_when(PRODUCTLINE == "Motorcycles" ~ "Motorcycles",
                                      PRODUCTLINE == "Classic Cars" ~ "Classic Cars",
                                      PRODUCTLINE == "Trucks and Buses" ~ "Trucks and Buses",
                                      PRODUCTLINE == "Vintage Cars" ~ "Vintage Cars",
                                      PRODUCTLINE == "Planes" ~ "Planes",
                                      PRODUCTLINE == "Ships" ~ "Ships",
                                      PRODUCTLINE == "Trains" ~ "Trains")) %>%
      group_by(product_line) %>%
      summarise(median_pl_value = median(SALES)),
    by = "product_line"
  )
```

Lines 42-51:  
Create a summary data table to rank product lines by no_of_product_codes and median_pl_value.
```r  
pl_summary <- sales %>%
  group_by(product_line) %>%
  select(product_line, median_pl_value, no_of_product_codes) %>%
  summarise_all(funs(median)) %>%
  mutate_if(is.numeric, round, 0) %>%
  arrange(desc(median_pl_value)) %>%
  datatable(rownames = FALSE, class = "table",
    options = list(pageLength = 10, scrollX = T),
    colnames = c("Product Line", "Median Product Line Value (US$)", "No. of Product Codes")
  )
```

![Table1](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/tables/table1.jpg)

Lines 53-59:  
Create a detailed data table to rank product lines by no_of_product_codes and median_pl_value.
```r  
order_table <- sales %>%
  group_by(YEAR_ID) %>%
  select(YEAR_ID, MONTH_ID, PRODUCTLINE, PRODUCTCODE, ORDERNUMBER, SALES) %>%
  arrange(YEAR_ID, MONTH_ID, PRODUCTLINE, PRODUCTCODE, ORDERNUMBER) %>%
  datatable(., rownames = FALSE, class = "table",
            options = list(pageLength = 10, scrollX = T),
            colnames = c("Year", "Month", "Product Line", "Product Code", "Order Number", "Order Value (US$)"))
```

![Table2](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/tables/table2.gif)

Lines 61-65:  
Create a variable to calculate the median product code value.
```r  
median_pc_value <- sales %>%
  group_by(PRODUCTCODE) %>%
  summarise(median_pc_value = median(SALES)) %>%
  arrange(desc(median_pc_value))
sales <- left_join(sales, median_pc_value, by = "PRODUCTCODE")
```

Lines 67-74:  
Create a variable to calculate the total product line value (in numerical, and percentage form).
```r  
total_pl_value <- sales %>%
  group_by(product_line) %>%
  summarise(total_pl_value = sum(SALES))

total_pl_value <- total_pl_value %>%
  mutate(total_pl_value_pct = total_pl_value / sum(total_pl_value) * 100)

QUANTITYORDERED <- sales$QUANTITYORDERED
```

Lines 80-89:  
Create a bar chart to rank the median product code value, from highest to lowest.
```r  
overall_pc <- ggplot(median_pc_value, aes(x = reorder(PRODUCTCODE, median_pc_value), y = median_pc_value)) +
  geom_col(aes(fill = reorder(PRODUCTCODE, median_pc_value))) +
  theme_bw() +
  labs(title = "Distribution of Product Codes by Median Value",
       y = "Median Value (US$)") +
  theme(legend.position = "none",
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.title = element_text(hjust = 0.5, vjust = 0.5))
```

![Plot1](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/plots/plot1.jpg)

Lines 91-100:  
Create a bar chart to rank the median product code value, from highest to lowest (for Top 10).
```r  
top_10_pc <- median_pc_value %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(PRODUCTCODE, median_pc_value), y = median_pc_value, color = PRODUCTCODE)) +
  geom_bar(stat = "identity") +
  labs(title = "Ranking of Product Codes by Median Value (Top 10)",
       x = "Product Code",
       y = "Median Sales Value (US$)") +
  coord_flip() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))
```

![Plot2](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/plots/plot2.jpg)

Lines 102-111:  
reate a bar chart to rank the median product code value, from highest to lowest (for Bottom 10).
```r  
bottom_10_pc <- median_pc_value %>%
  top_n(10, -median_pc_value) %>%
  ggplot(aes(x = reorder(PRODUCTCODE, median_pc_value), y = median_pc_value)) +
  geom_bar(stat = "identity") +
  labs(title = "Ranking of Product Codes by Median Value (Bottom 10)",
       x = "Product Code",
       y = "Median Sales Value (US$)") +
  coord_flip() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))
```

![Plot3](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/plots/plot3.jpg)

Lines 113-122:  
Create a scatterplot which shows each product code in two dimensions (product line, and median product code value).
```r  
scatterplot_pc <- ggplot(sales, aes(x = product_line, y = median_pc_value, color = product_line)) +
  geom_point(size = 2) +
  labs(title = "Scatterplot of Median Sales Value by Product Line",
       x = " ",
       y = "Median Sales Value (US$)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5) +
        scale_color_brewer(type = "qual"))
```

![Plot4](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/plots/plot4.jpg)

Lines 124-134:  
Create a pie chart to understand the Product Line by Total Sales (in %).
```r  
piechart_pl <- ggplot(total_pl_value, aes(x = "", y = total_pl_value, fill = product_line)) +
  geom_bar(stat = "identity", width = 1, 
           color = "black", linewidth = 1) +
  theme_void() +
  coord_polar("y", start = 0) +
  labs(title = "Product Line by Total Sales (in %)", x = "", y = "Total Sales (US$)") +
  theme(legend.position = "right",
        legend.title = element_blank(),
        plot.title = element_text(hjust = 0.5, vjust = 1)) +
  geom_text(aes(label = paste0(round(total_pl_value_pct, 1), "%")), 
            position = position_stack(vjust = 0.5))
```

![Plot5](https://github.com/dwoo-work/data-visualisations-with-R/blob/main/plots/plot5.jpg)

## Credit

Sales Data Sample (https://www.kaggle.com/datasets/kyanyoga/sample-sales-data)

## License

[MIT](https://choosealicense.com/licenses/mit/)
