
###########################################
# PART 1 - PREPARE THE DATAFRAME NEEDED ###
###########################################

required_libraries <- c("readr", "dplyr", "DT", "ggplot2")
lapply(required_libraries, require, character.only = TRUE)

sales <- read_csv("sales_data_sample_utf8.csv")
glimpse(sales)

unique_values <- apply(sales, 2, unique)

##################################################
# PART 2 - CREATE BASIC ALGORITHM FOR ANALYSIS ###
##################################################

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

order_table <- sales %>%
  group_by(YEAR_ID) %>%
  select(YEAR_ID, MONTH_ID, PRODUCTLINE, PRODUCTCODE, ORDERNUMBER, SALES) %>%
  arrange(YEAR_ID, MONTH_ID, PRODUCTLINE, PRODUCTCODE, ORDERNUMBER) %>%
  datatable(., rownames = FALSE, class = "table",
            options = list(pageLength = 10, scrollX = T),
            colnames = c("Year", "Month", "Product Line", "Product Code", "Order Number", "Order Value (US$)"))

median_pc_value <- sales %>%
  group_by(PRODUCTCODE) %>%
  summarise(median_pc_value = median(SALES)) %>%
  arrange(desc(median_pc_value))
sales <- left_join(sales, median_pc_value, by = "PRODUCTCODE")

total_pl_value <- sales %>%
  group_by(product_line) %>%
  summarise(total_pl_value = sum(SALES))

total_pl_value <- total_pl_value %>%
  mutate(total_pl_value_pct = total_pl_value / sum(total_pl_value) * 100)

QUANTITYORDERED <- sales$QUANTITYORDERED

####################################
# PART 3 - CREATE VISUALISATIONS ###
####################################

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