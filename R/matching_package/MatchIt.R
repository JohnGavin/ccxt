# https://statsnotebook.io/blog/analysis/matching/

library(tidyverse)
currentDataset <- read_csv("https://raw.githubusercontent.com/gckc123/ExampleData/main/smoking_psyc_distress.csv")

currentDataset$remoteness <- factor(currentDataset$remoteness, exclude = c("", NA))

#The MatchIt, lmtest and sandwich libraries are used.
pacman::p_load(MatchIt, lmtest, sandwich)

#Using the mathcit function from MatchIt to match each smoker with a non-smoker (1 to 1 matching) based on
#sex, indigeneity status, high school completion, marital status (partnered or not),
#region of residence (major cities, inner regional, outer regional), language background (English speaking Yes/No) 
#and risky alcohol drinking (Yes/No)

match_obj <- matchit(smoker ~ sex + indigeneity + high_school + partnered + remoteness + language + risky_alcohol + age,
	data = currentDataset, method = "nearest", distance ="glm",
	ratio = 1,
	replace = FALSE)
summary(match_obj)

#plotting the balance between smokers and non-smokers
plot(match_obj, type = "jitter", interactive = FALSE)
plot(summary(match_obj), abs = FALSE)


#Extract the matched data and save the data into the variable matched_data
matched_data <- match.data(match_obj)

#Run regression model with psychological distress as the outcome, and smoker as the only predictor
#We need to specify the weights - Matched participants have a weight of 1, unmatched participants 
res <- lm(psyc_distress ~ smoker, data = matched_data, weights = weights)

#Test the coefficient using cluster robust standard error
coeftest(res, vcov. = vcovCL, cluster = ~subclass)
#Calculate the confidence intervals based on cluster robust standard error
coefci(res, vcov. = vcovCL, cluster = ~subclass, level = 0.95)
