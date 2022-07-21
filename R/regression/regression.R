# https://docs.microsoft.com/en-us/learn/modules/introduction-regression-models/3-exercise-train-evaluate-regression-model

# Setup chunk to install and load required packages
knitr::opts_chunk$set(warning = FALSE, 
  message = FALSE, include = FALSE)
suppressWarnings(if(!require("pacman")) 
  install.packages("pacman"))

pacman::p_load(tidyverse, 'tidymodels', 'glmnet',
  'randomForest', 'xgboost','patchwork',
  'paletteer', 'here', 'doParallel', 'summarytools')

library(tidyverse)

# Import the data into the R session
bike_data <- read_csv(file = "https://raw.githubusercontent.com/MicrosoftDocs/ml-basics/master/data/daily-bike-share.csv", show_col_types = FALSE)

# View first few rows
bike_data %>% 
  slice_head(n = 7)


library(lubridate)

# Parse dates then extract days
bike_data <- bike_data %>%
  # Parse dates
  mutate(dteday = mdy(dteday)) %>% 
  #Get day
  mutate(day = day(dteday))

# extract the first 10 rows
bike_data %>% 
  slice_head(n = 10)


# load package into the R session
library(summarytools)

# Obtain summary stats for feature and label columns
bike_data %>% 
  # Select features and label
  select(c(temp, atemp, hum, windspeed, rentals)) %>% 
  # Summary stats
  descr(order = "preserve",
    stats = c('mean', 'sd', 'min', 'q1', 'med', 'q3', 'max'),
    round.digits = 6)



library(patchwork)
library(paletteer) # Collection of color palettes
theme_set(theme_light())

# Plot a histogram
hist_plt <- bike_data %>% 
  ggplot(mapping = aes(x = rentals)) + 
  geom_histogram(bins = 100, fill = "midnightblue", alpha = 0.7) +
  
  # Add lines for mean and median
  geom_vline(aes(xintercept = mean(rentals), color = 'Mean'), linetype = "dashed", size = 1.3) +
  geom_vline(aes(xintercept = median(rentals), color = 'Median'), linetype = "dashed", size = 1.3 ) +
  xlab("") +
  ylab("Frequency") +
  scale_color_manual(name = "", values = c(Mean = "red", Median = "yellow")) +
  theme(legend.position = c(0.9, 0.9), legend.background = element_blank())

# Plot a box plot
box_plt <- bike_data %>% 
  ggplot(aes(x = rentals, y = 1)) +
  geom_boxplot(fill = "#E69F00", color = "gray23", alpha = 0.7) +
  # Add titles and labels
  xlab("Rentals")+
  ylab("")


# Combine plots
(hist_plt / box_plt) +
  plot_annotation(title = 'Rental Distribution',
    theme = theme(plot.title = element_text(hjust = 0.5)))




# Create a data frame of numeric features & label
numeric_features <- bike_data %>% 
  select(c(temp, atemp, hum, windspeed, rentals))

# Pivot data to a long format
numeric_features <- numeric_features %>% 
  pivot_longer(!rentals, names_to = "features", values_to = "values") %>%
  group_by(features) %>% 
  mutate(Mean = mean(values),
    Median = median(values))


# Plot a histogram for each feature
numeric_features %>%
  ggplot() +
  geom_histogram(aes(x = values, fill = features), bins = 100, alpha = 0.7, show.legend = F) +
  facet_wrap(~ features, scales = 'free')+
  paletteer::scale_fill_paletteer_d("ggthemes::excel_Parallax") +
  
  # Add lines for mean and median
  geom_vline(aes(xintercept = Mean, color = "Mean"), linetype = "dashed", size = 1.3 ) +
  geom_vline(aes(xintercept = Median, color = "Median"), linetype = "dashed", size = 1.3 ) +
  scale_color_manual(name = "", values = c(Mean = "red", Median = "yellow")) 



# Create a data frame of categorical features & label
categorical_features <- bike_data %>% 
  select(c(season, mnth, holiday, weekday, workingday, weathersit, day, rentals))

# Pivot data to a long format
categorical_features <- categorical_features %>% 
  pivot_longer(!rentals, names_to = "features", values_to = "values") %>%
  group_by(features) %>% 
  mutate(values = factor(values))


# Plot a bar plot for each feature
categorical_features %>%
  ggplot() +
  geom_bar(aes(x = values, fill = features), alpha = 0.7, show.legend = F) +
  facet_wrap(~ features, scales = 'free') +
  paletteer::scale_fill_paletteer_d("ggthemr::solarized") +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90))




# Plot a scatter plot for each feature
numeric_features %>% 
  mutate(corr_coef = cor(values, rentals)) %>%
  mutate(features = paste(features, ' vs rentals, r = ', corr_coef, sep = '')) %>% 
  ggplot(aes(x = values, y = rentals, color = features)) +
  geom_point(alpha = 0.7, show.legend = F) +
  facet_wrap(~ features, scales = 'free')+
  paletteer::scale_color_paletteer_d("ggthemes::excel_Parallax")




# Calculate correlation coefficient
numeric_features %>% 
  summarise(corr_coef = cor(values, rentals))


# Plot a box plot for each feature
categorical_features %>%
  ggplot() +
  geom_boxplot(aes(x = values, y = rentals, fill = features), alpha = 0.9, show.legend = F) +
  facet_wrap(~ features, scales = 'free') +
  paletteer::scale_fill_paletteer_d("tvthemes::simpsons")+
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90))


# Select desired features and labels
bike_select <- bike_data %>% 
  select(c(season, mnth, holiday, weekday, workingday, weathersit,
    temp, atemp, hum, windspeed, rentals)) %>% 
  # Encode certain features as categorical
  mutate(across(1:6, factor))

# Get a glimpse of your data
glimpse(bike_select)




# Load the Tidymodels packages
library(tidymodels)

# Split 70% of the data for training and the rest for testing
set.seed(2056)
bike_split <- bike_select %>% 
  initial_split(prop = 0.7,
    # splitting data evenly on the holiday variable
    strata = holiday)

# Extract the data in each split
bike_train <- training(bike_split)
bike_test <- testing(bike_split)


cat("Training Set", nrow(bike_train), "rows",
  "\nTest Set", nrow(bike_test), "rows")




# Build a linear model specification
lm_spec <- 
  # Type
  linear_reg() %>% 
  # Engine
  set_engine("lm") %>% 
  # Mode
  set_mode("regression")



# Train a linear regression model
lm_mod <- lm_spec %>% 
  fit(rentals ~ ., data = bike_train)

# Print the model object
lm_mod



# Make predictions on test set
pred <- lm_mod %>% 
  predict(new_data = bike_test)

# View predictions
pred %>% 
  slice_head(n = 5)


# Predict rentals for the test set and bind it to the test_set
results <- bike_test %>% 
  bind_cols(lm_mod %>% 
      # Predict rentals
      predict(new_data = bike_test) %>% 
      rename(predictions = .pred))

# Compare predictions
results %>% 
  select(c(rentals, predictions)) %>% 
  slice_head(n = 10)



# Visualise the results
results %>% 
  ggplot(mapping = aes(x = rentals, y = predictions)) +
  geom_point(size = 1.6, color = "steelblue") +
  # Overlay a regression line
  geom_smooth(method = "lm", se = F, color = 'magenta') +
  ggtitle("Daily Bike Share Predictions") +
  xlab("Actual Labels") +
  ylab("Predicted Labels") +
  theme(plot.title = element_text(hjust = 0.5))



# Multiple regression metrics
eval_metrics <- metric_set(rmse, rsq)

# Evaluate RMSE, R2 based on the results
eval_metrics(data = results,
  truth = rentals,
  estimate = predictions)
