# https://cran.r-project.org/web/packages/qad/vignettes/qad-vignette.html

# install.packages("qad")
library(qad)
# Some basic instructions for the main functions in qad can be found with

# help("qad") ; help("qad-package")

set.seed(1)

## Step 1: Generate sample 
n <- 100
#Underlying Model Y = sin(X) + small.error
X <- runif(n, -10, 10)
Y <- sin(X) + rnorm(n, 0, 0.1)
#Plot the sample 
plot(X,Y, pch = 16)

fit <- qad(X,Y, p.value = T, p.value_asymmetry = T)



