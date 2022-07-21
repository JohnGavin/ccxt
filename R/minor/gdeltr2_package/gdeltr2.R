# https://github.com/abresler/gdeltr2
library(gdeltr2)
load_needed_packages(c('dplyr', 'magrittr'))

events_1989 <-
  get_data_gdelt_periods_event(
    periods = 1989,
    return_message = T
  )


gkg_summary_count_may_15_16_2014 <-
  get_data_gkg_days_summary(
    dates = c('2014-05-15', '2014-05-16'),
    is_count_file = T,
    return_message = T
  )

gkg_full_june_2_2016 <-
  get_data_gkg_days_detailed(
    dates = c("2016-06-02"),
    table_name = 'gkg',
    return_message = T
  )

gkg_mentions_may_12_2016 <-
  get_data_gkg_days_detailed(
    dates = c("2016-05-12"),
    table_name = 'mentions',
    return_message = T
  )
GKG Television Data
gkg_tv_test <- 
  get_data_gkg_tv_days(dates = c("2016-06-17", "2016-06-16"))
GKG Tidying
load_needed_packages(c('magrittr'))

gkg_test <- 
  get_data_gkg_days_detailed(only_most_recent = T, table_name = 'gkg')

gkg_sample_df <- 
  gkg_test %>% 
  sample_n(1000)

xml_extra_df <- 
  gkg_sample_df %>% 
  parse_gkg_xml_extras(filter_na = T, return_wide = F)

article_tone <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_article_tone(filter_na = T, return_wide = T)

gkg_dates <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_dates(filter_na = T, return_wide = T)

gkg_gcams <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_gcams(filter_na = T, return_wide = T)

gkg_event_counts <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_event_counts(filter_na = T, return_wide = T)

gkg_locations <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_locations(filter_na = T, return_wide = T)

gkg_names <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_names(filter_na = T, return_wide = T)

gkg_themes <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_themes(theme_column = 'charLoc',
    filter_na = T, return_wide = T)

gkg_numerics <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_numerics(filter_na = T, return_wide = T)

gkg_orgs <-
  gkg_sample_df %>% 
  parse_gkg_mentioned_organizations(organization_column = 'charLoc', 
    filter_na = T, return_wide = T)

gkg_quotes <-
  gkg_sample_df %>% 
  parse_gkg_mentioned_quotes(filter_na = T, return_wide = T)

gkg_people <- 
  gkg_sample_df %>% 
  parse_gkg_mentioned_people(people_column = 'charLoc', filter_na = T, return_wide = T)
VGKG Tidying
vgkg_test <- 
  get_data_vgkg_dates(only_most_recent = T)

vgkg_sample <- 
  vgkg_test %>% 
  sample_n(1000)

vgkg_labels <- 
  vgkg_sample %>% 
  parse_vgkg_labels(return_wide = T)

faces_test <- 
  vgkg_sample %>% 
  parse_vgkg_faces(return_wide = T)

landmarks_test <- 
  vgkg_sample %>% 
  parse_vgkg_landmarks(return_wide = F)

logos_test <- 
  vgkg_sample %>% 
  parse_vgkg_logos(return_wide = T)

ocr_test <- 
  vgkg_sample %>% 
  parse_vgkg_ocr(return_wide = F)

search_test <- 
  vgkg_sample %>% 
  parse_vgkg_safe_search(return_wide = F)
Sentiment API
location_codes <-
  dictionary_stability_locations()
location_test <-
  instability_api_locations(
    location_ids = c("US", "IS", "CA", "TU", "CH", "UK", "IR"),
    use_multi_locations = c(T, F),
    variable_names = c('instability', 'tone', 'protest', 'conflict'),
    time_periods = c('daily'),
    nest_data = F,
    days_moving_average = NA,
    return_wide = T,
    return_message = T
  )

location_test %>%
  dplyr::filter(codeLocation %>% is.na()) %>%
  group_by(nameLocation) %>%
  summarise_at(.vars = c('instability', 'tone', 'protest', 'conflict'),
    funs(mean)) %>%
  arrange(desc(instability))location_codes <-
  dictionary_stability_locations()
location_test <-
  instability_api_locations(
    location_ids = c("US", "IS", "CA", "TU", "CH", "UK", "IR"),
    use_multi_locations = c(T, F),
    variable_names = c('instability', 'tone', 'protest', 'conflict'),
    time_periods = c('daily'),
    nest_data = F,
    days_moving_average = NA,
    return_wide = T,
    return_message = T
  )

location_test %>%
  dplyr::filter(codeLocation %>% is.na()) %>%
  group_by(nameLocation) %>%
  summarise_at(.vars = c('instability', 'tone', 'protest', 'conflict'),
    funs(mean)) %>%
  arrange(desc(instability))
