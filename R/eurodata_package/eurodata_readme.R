# https://cran.r-project.org/web/packages/eurodata/readme/README.html
#     https://ec.europa.eu/eurostat/data/bulkdownload/
#     information updated twice a day, at 11:00 and 23:00;
# devtools::install_github('alekrutkowski/eurodata') # package 'devtools' needs to be installed

library(eurodata)
x <- importData('nama_10_a10')  # actual dataset
str(x)
head(x,10)

y <- importDataList()  # metadata
colnames(y)
str(y[y$Code=='nama_10_a10',])  # metadata on x

z <- importLabels('geo')
head(z,10)

# Search
# Free-style text search based on the parts of 
#   words in the dataset names
find(gdp,main,international,-quarterly)

# Search based on the parts of the dataset codes
find(bop, its)

find(bop,-ybk,its)

browseDataList(
  grepl('GDP',`Dataset name`) &
  grepl('main',`Dataset name`) &
  grepl('international',`Dataset name`) &
  !grepl('quarterly',`Dataset name`))

browseDataList(grepl('bop',Code) & grepl('its',Code))



library(magrittr)
metab <- importMetabase()
## Downloading Eurostat Metabase

## Uncompressing (extracting)

## Importing (reading into memory)
codes_with_nace <- metab %>% 
  subset(Dim_name=='nace_r2') %>%
  extract2('Code') %>%
  unique
final_codes <- metab %>%
  subset(Dim_name=='sizeclas' & Dim_val=='LT10' &
      Code %in% codes_with_nace) %>%
  extract2('Code') %>%
  unique
importDataList() %>%
  subset(Code %in% final_codes) %>%
  as.EurostatDataList %>%
  # the `SearchCriteria` argument below is optional
  print(SearchCriteria =
      'those including data on firms with fewer than 10 employees and NACE Rev.2 disaggregation') 

describe('nama_10_gdp')
## Downloading Eurostat Metabase
describe('nama_10_gdp', wide=TRUE)
compare('nama_10_gdp', 'nama_10_a64')
