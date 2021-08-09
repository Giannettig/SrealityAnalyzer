
#' Get the number of listings on Sreality
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

  return(ifelse(is.na(number_of_listings),0,number_of_listings))
}


#' Returns pagination links from Sreality query
#'
#' @param sreality_query the url of a search query on sreality.cz
#'
#' @return a character vector of urls to scrape
#' @export
#'
#' @examples \dontrun{get_url_variants("https://www.sreality.cz/hledani/prodej/byty")}
get_url_variants<-function(sreality_query){

  listings<-get_sreality_listings(sreality_query)

  if(listings!=0){
  pages<-1:(ceiling(listings/20))

  url_list<-purrr::map_chr(pages, function(x){ urltools::param_set(sreality_query, key = "strana", value = x)})

  }

  else

  {
  url_list<-query
  pages<-1
  listings<-19
  }

  return( list(pages_url=url_list,listings=listings,pages=max(pages)) )
}


#' Parse scraped listings lists (paginations) into a dataframe
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

      #pagination_url
      page=html_dump_path%>%stringr::str_extract("[0-9]+$")%>%as.integer(),

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


#' Parse sreality listing detail into a dataframe
#'
#' This function takes the path to a dumped html file with a listing details and extracts most of the info there.
#' The param fields are downloades as a nested list in a single column to prevent data corruption on download.
#'
#' @param html_detail_path the path to the listing detail html file
#'
#' @return a tibble with the scraped attibutes
#' @export
#'
#' @examples
#' #' \dontrun{parse_flat_detail("data/sreality_listing_detail.html")}
#'
parse_flat_detail<-function(html_detail_path){

  html<-rvest::read_html(html_detail_path)

  #get the flat param names and
  labels<-html%>%rvest::html_element(".params1")%>%rvest::html_children()%>%rvest::html_elements(".param-value")%>%rvest::html_text()%>%stringr::str_squish()
  content<-html%>%rvest::html_element(".params1")%>%rvest::html_children()%>%rvest::html_elements(".param-label")%>%rvest::html_text()
  params=stats::setNames(labels,content)%>%as.list()%>%dplyr::as_tibble()


  flat_info<-
    dplyr::tibble(

      name=html%>%rvest::html_element(".name")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      url=html%>%rvest::html_elements(xpath="//*[@property='og:url']")%>%rvest::html_attr("content")%>%ifelse(is.null(.),"",.),
      id=html%>%rvest::html_elements(xpath="//*[@property='og:url']")%>%rvest::html_attr("content")%>%stringr::str_extract("[0-9]+$")%>%ifelse(is.null(.),"",.),
      location=html%>%rvest::html_element(".location-text")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      price=html%>%rvest::html_elements(".price")%>%rvest::html_elements(xpath="//*[@itemprop='price']")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      price_type=ifelse(stringr::str_detect(html_detail_path,"pronajem"),"rent",ifelse(stringr::str_detect(html_detail_path,"prodej"),"sale","other")),
      currency=html%>%rvest::html_elements(".price")%>%rvest::html_elements(xpath="//*[@itemprop='currency']")%>%rvest::html_attr("content")%>%ifelse(is.null(.),"",.),
      energy_rating=html%>%rvest::html_elements(".price")%>%rvest::html_elements(".energy-efficiency-rating__type")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      energy_rating_text=html%>%rvest::html_elements(".price")%>%rvest::html_elements(".energy-efficiency-rating__text")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      description=html%>%rvest::html_elements(".description")%>%rvest::html_text()%>%ifelse(is.null(.),"",.),
      agent_name=html%>%rvest::html_elements(".seller-name")%>%rvest::html_text()%>%stringr::str_squish()%>%ifelse(is.null(.),"",.),
      agent_url=html%>%rvest::html_elements(".seller-name a")%>%rvest::html_attr("href")%>%ifelse(is.null(.),"",.),
      agency_name=html%>%rvest::html_elements(".info")%>%rvest::html_elements(".name")%>%rvest::html_text()%>%stringr::str_squish()%>%ifelse(is.null(.),"",.),
      agency_url=html%>%rvest::html_elements(".info a")%>%rvest::html_elements(xpath="//*[@data-dot='webovka RK']")%>%rvest::html_attr("href")%>%ifelse(is.null(.),"",.),
      params=tidyr::nest(params, data=tidyr::everything()))

  return(flat_info)

}




# #enrich geocoding and add information
# library('tidygeocoder')
#
# # go through google api
# Sys.setenv(GOOGLEGEOCODE_API_KEY="AIzaSyCILf2H3etN0h5iXpUJI3A1mzR1XwY4Dtc")
#
# google_longs<- out_stores%>%
#   geocode(store_adress, method = 'google', lat = latitude , long = longitude,unique_only = T, full_results = T)
#
# #test<-google_longs[[4]][[10]]
#
#
# unpivot_location<-function(df){
#   df<-as_tibble(df)
#
#   if(("types" %in% names(df))) {
#
#     df%>%mutate(type=types%>%map(1)%>%unlist)%>%
#       filter(type %in% c("locality","country","administrative_area_level_1"))%>%
#       select(type,short_name)%>%
#       pivot_wider(values_from  = short_name, names_from = type)
#   }else tibble(locality="", country="",administrative_area_level_1="")
# }
#
# df<-google_longs$address_components%>%map_df(unpivot_location)
#
# df<-df%>%bind_cols(google_longs)
#
# dupl_longs<-google_longs[duplicated(google_longs$address),]
#
# #write the result
# write_csv(google_longs,"out_data/lat_long.csv")

