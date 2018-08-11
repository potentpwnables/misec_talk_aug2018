suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(xml2))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(dplyr))

if (!file.exists('~/Projects/misec_talk/data/reuters.csv')) {
    url = 'http://www.reuters.com/news/technology/'
    html = read_html(url)

    stories = html %>%
        html_nodes('.FeedItem_item')

    links = stories %>%
        html_nodes('h2 > a') %>%
        html_attr('href')

    titles = stories %>%
        html_nodes('h2 > a') %>%
        html_text()

    ledes = stories %>%
        html_nodes('.FeedItemLede_lede') %>%
        html_text()

    df = data_frame(site='Reuters',
                    date_parsed=Sys.Date(),
                    title=titles,
                    lede=ledes,
                    url=links)
                    

    write_csv(df, '~/Projects/misec_talk/data/reuters.csv')
} else {
    df = read_csv('~/Projects/misec_talk/data/reuters.csv', col_types='ccccc')
}

print(head(df, 10))
