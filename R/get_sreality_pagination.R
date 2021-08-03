
#' Get the number of listing on a specific Sreality.cz search query
#'
#' @param sreality_query the url of a search query on sreality.cz
#'
#' @return the number of listings to be found on the site
#' @export
#'
#' @examples \dontrun{get_sreality_listings("https://www.sreality.cz/hledani/prodej/byty")}
get_sreality_listings<-function(sreality_query){

         query_result<-dump_DOM(sreality_query)
         parsed_html<-rvest::read_html(query_result)

  number_of_listings<-parsed_html%>%
    rvest::html_elements(".numero.ng-binding")%>%
    rvest::html_text()%>%.[2]%>%stringr::str_remove_all("\\s")%>%
    as.numeric()
}


#' Returns pagination variants of a Sreality query
#'
#' @param sreality_query the url of a search query on sreality.cz
#'
#' @return a character vector of urls to scrape
#' @export
#'
#' @examples \dontrun{get_url_variants("https://www.sreality.cz/hledani/prodej/byty")}
get_url_variants<-function(sreality_query){

  listings<-get_sreality_listings(sreality_query)
  pages<-1:(ceiling(listings/20))

  url_list<-purrr::map_chr(pages, function(x){ urltools::param_set(sreality_query, key = "strana", value = x)})
}



