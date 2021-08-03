
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SrealityAnalyzer

<!-- badges: start -->
<!-- badges: end -->

The goal of SrealityAnalyzer is to …

## Installation

You can install the released version of SrealityAnalyzer from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("SrealityAnalyzer")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Giannettig/SrealityAnalyzer")
```

## Example

This is a basic example which shows you how to solve a common problem:

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
## basic example code

url_prodej<-"https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj"
url_pronajem<-"https://www.sreality.cz/hledani/pronajem/byty/ustecky-kraj,karlovarsky-kraj,stredocesky-kraj"

#takhle nastavím parametry v adrese
url<- urltools::param_set(url_prodej, key = "bez-aukce", value = "1")%>%
      urltools::param_set( key = "vlastnictvi", value = "osobni")%>%
      urltools::param_set( key = "stari", value = "tyden")%>%
      urltools::param_set( key = "strana", value = "14")

byty_prodej_7dni<-rvest::read_html(url)
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/master/examples>.

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
