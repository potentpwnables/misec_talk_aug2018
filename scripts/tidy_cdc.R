suppressPackageStartupMessages(library(tidyverse))
library(xml2)

xml = read_xml('~/Projects/misec_talk/data/cdc_raw.xls')
raw = xml %>%
  xml_find_first('.//ss:Table') %>%
  xml_find_all('.//ss:Data') %>%
  xml_text()

vaccinations = raw[1:6] %>%
  stringr::str_replace('.* - ', '')

columns = raw[13:265] %>%
  tolower() %>%
  stringr::str_replace_all('[\\s-]', '_')

data = tail(raw, -265)

tmp = data %>%
  tbl_df() %>%
  mutate(group = (row_number() - (row_number() %% -253)) / 253) %>%
  group_by(group) %>%
  mutate(var = columns) %>%
  ungroup() %>%
  split(.$group)

convert = function(data) {
  state = data$value[data$var == 'names']
  data = data %>%
    slice(-1) %>%  
    mutate(group = (row_number() - (row_number() %% -6)) / 6) %>%
    split(.$group) %>%
    map_df(function(x) spread(x, var, value)) %>%
    mutate(state=state) %>% 
    select(state, survey_type, total_kindergarten_population,
           percent_surveyed, target, footnotes, `2009_10`,
           `2010_11`, `2011_12`, `2012_13`, `2013_14`,
           `2014_15`, `2015_16`) %>%
    gather(key=year, value=percent_vaccinated, `2009_10`:`2015_16`)
  return(data)
}

vaccinations = rep(vaccinations, times=7)

df = map_df(tmp, convert) %>%
  filter(!is.na(percent_vaccinated)) %>%
  mutate(vaccination = rep(vaccinations, times=53)) %>%
  arrange(state, vaccination, year)

write_csv(df, '~/Projects/misec_talk/data/cdc_clean.csv')
