
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SrealityAnalyzer

<!-- badges: start -->
<!-- badges: end -->

The goal of SrealityAnalyzer is to provide a set of util libraries for
the analysis of Sreality data. For more information regarding Sreality
API check\[<https://admin.sreality.cz/doc/import.pdf>\]

## Installation

You can install the released version of SrealityAnalyzer from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("SrealityAnalyzer")
```

And the development version from
[GitHub](https://github.com/Giannettig/SrealityAnalyzer) with:

``` r
# install.packages("devtools")
devtools::install_github("Giannettig/SrealityAnalyzer")
```

## Example

Lets take a look how we can download data for a particular sreality
query. Go to www.sreality.cz and in the search select the atributes of
the flats you are interested in.

Then:

``` r
library(SrealityAnalyzer)
library(urltools)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
## This is an example of a query of the flats to buy and Rent

url_prodej<-"https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj"
url_pronajem<-"https://www.sreality.cz/hledani/pronajem/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj"

#You can use url tools to alter the query. 
url<- urltools::param_set(url_prodej, key = "bez-aukce", value = "1")%>%
      urltools::param_set( key = "vlastnictvi", value = "osobni")%>%
      urltools::param_set( key = "stari", value = "tyden")

print(url)
#> [1] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden"
```

## Get the pagination urls

Now that we have our query we need to figure out the number of listings
and the pagination links to iterate through the server.

You gan use the function get\_url\_variants for that the function hits
the query, figures out the number of pages to scroll and returns the
urls with the page number to get through later.

Note the `-blink-settings=imagesEnabled=false` argument that disables
loading images.

``` r
## Take a search query and return pagination links

pagination_links<-get_url_variants(url)
#> Running '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
#>   --no-first-run --headless \
#>   '--user-data-dir=/Users/giannettig/Library/Application Support/r-crrri/chrome-data-dir-wskhjwwh' \
#>   '--remote-debugging-port=9222' '--blink-settings=imagesEnabled=false'

print(pagination_links)
#> $pages_url
#>  [1] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=1" 
#>  [2] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=2" 
#>  [3] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=3" 
#>  [4] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=4" 
#>  [5] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=5" 
#>  [6] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=6" 
#>  [7] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=7" 
#>  [8] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=8" 
#>  [9] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=9" 
#> [10] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=10"
#> [11] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=11"
#> [12] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&strana=12"
#> 
#> $listings
#> [1] 235
#> 
#> $pages
#> [1] 12
```

## Download the listings lists for all the pages.

Now that we have the links lets download all the HTML files for further
scrutiny

``` r
#stáhni urls
save_as_html( pagination_links$pages_url , output_dir = "data/html_dump")
#> Running '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
#>   --no-first-run --headless \
#>   '--user-data-dir=/Users/giannettig/Library/Application Support/r-crrri/chrome-data-dir-rqkjedsf' \
#>   '--remote-debugging-port=9222' '--blink-settings=imagesEnabled=false'
```

## Now we can analyze the listings dumps and extract links to the detail

``` r
#vytvoř dataframe se základníma informacema o bytech odkaze na detail
html_list<-list.files(path = "./data/html_dump", pattern = ".html", all.files = FALSE,
           full.names = TRUE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

html_details<-purrr::map_df(html_list,get_page_info)

html_details
#> # A tibble: 235 x 5
#>    name        id      url                            locality           price  
#>    <chr>       <chr>   <chr>                          <chr>              <chr>  
#>  1 Prodej byt… 148200… https://www.sreality.cz/detai… Hroznatova, Mariá… 1 560 …
#>  2 Prodej byt… 327717… https://www.sreality.cz/detai… Armádní, Milovice… 2 890 …
#>  3 Prodej byt… 581352… https://www.sreality.cz/detai… Vítkovická, Nymbu… 3 950 …
#>  4 Prodej byt… 122006… https://www.sreality.cz/detai… Benešova, Kolín -… 3 800 …
#>  5 Prodej byt… 259140… https://www.sreality.cz/detai… Moskevská, Most    1 199 …
#>  6 Prodej byt… 157657… https://www.sreality.cz/detai… Za Cukrovarem, Ce… 3 250 …
#>  7 Prodej byt… 403319… https://www.sreality.cz/detai… Karla Nového, Ben… 3 100 …
#>  8 Prodej byt… 149708… https://www.sreality.cz/detai… Pod Hájem, Králův… 4 500 …
#>  9 Prodej byt… 966175… https://www.sreality.cz/detai… Máchova, Poděbrad… 5 950 …
#> 10 Prodej byt… 741784… https://www.sreality.cz/detai… Anglická, Kladno … 4 990 …
#> # … with 225 more rows
```

\#Get listing detail

Now that we have all the urls of the listing details we need to download
we can use the utils functions we used before to download the listing
details.

``` r
#Save all the urls as html documents for further analysis
save_as_html( html_details$url , output_dir = "data/detail_dump")
#> Running '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
#>   --no-first-run --headless \
#>   '--user-data-dir=/Users/giannettig/Library/Application Support/r-crrri/chrome-data-dir-trlzjbju' \
#>   '--remote-debugging-port=9222' '--blink-settings=imagesEnabled=false'

html_list<-list.files(path = "./data/detail_dump", pattern = ".html", all.files = FALSE,
           full.names = TRUE, recursive = FALSE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)
```

\#Parse listing details

Now that we got all the listings downloaded we need to parse out of them
the information we need for further analysis

``` r
#Go through the list of downloaded data and make a dataframe
parsed_details<-purrr::map_df(html_list,parse_flat_detail)
```

\#Wrap up

Now I need to write a function that logs, does a rerun of failed
downloads and testing
