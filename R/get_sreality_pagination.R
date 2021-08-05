
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

  return(number_of_listings)
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

  return( list(pages_url=url_list,listings=listings,pages=max(pages)) )
}


#' Returns the extracted data from the html dumps from the listings page
#'
#' @param html_dump_path The path to a respective html dump of a listings page
#'
#' @return A tibble with extracted url, name, location and price
#' @export
#'
#' @examples
#' \dontrun{get_page_info("html_dump/page.html")}
get_page_info<-function(html_dump_path){


  listings<-rvest::read_html(html_dump_path)%>%rvest::html_elements(".basic")


  purrr::map_df(listings, function(x){

    #alter the domain to contain the whole path
    url_snip<-x%>%rvest::html_element("a")%>%rvest::html_attr("href")
    urltools::domain(url_snip) <-"https://www.sreality.cz"

    dplyr::tibble(

      #name
      name=x%>%rvest::html_element("a")%>%rvest::html_text()%>%stringr::str_squish(),

      #ids
      id=stringr::str_extract(url_snip,"[0-9]+$"),

      #links
      url=url_snip,

      #locality
      locality=x%>%rvest::html_element(".locality")%>%rvest::html_text()%>%stringr::str_squish(),

      #cena
      price=x%>%rvest::html_element(".norm-price")%>%rvest::html_text()%>%stringr::str_squish()

    )

  })

}



