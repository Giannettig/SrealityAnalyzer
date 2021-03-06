
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
query<- urltools::param_set(url_prodej, key = "bez-aukce", value = "1")%>%
      urltools::param_set( key = "vlastnictvi", value = "osobni")%>%
      urltools::param_set( key = "stari", value = "tyden")%>%
      urltools::param_set( key = "navic", value = "terasa,parkovani")

print(query)
#> [1] "https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj?bez-aukce=1&vlastnictvi=osobni&stari=tyden&navic=terasa,parkovani"
```

## Download the listings

Now that we have the listings we can use the function
`scrape_sreality()` To download the listings on the query. The function
creates in the working directory a temp folder, where you can find the
downloaded csv with the sreality listings and a log file describing the
run of the scraper.

Note that if there are less than 20 listings on the selected query there
is no pagination so we assume there are 19 listings since we cannot
check the real number.

``` r
library(SrealityAnalyzer)
# scrape_sreality(query)
```
