suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(tidyverse))

logs = read_lines('~/Projects/misec_talk/data/auth.log')
date = logs %>%
    str_extract('[AFJDNOS][a-z]{2}\\s+\\d{1,2}')
time = logs %>%
    str_extract('\\d\\d:\\d\\d:\\d\\d')
user = logs %>%
    str_extract('(?<=\\d\\s)[a-z_][\\w\\d_-]+')
process = logs %>%
    str_extract('[a-z-]+(\\[\\d+\\])?(?=:)')
description = logs %>%
    str_extract('(?<=:\\s).+?$')

df = data_frame(date=date, time=time, user=user, process=process, description=description)
print(head(df, 10))
