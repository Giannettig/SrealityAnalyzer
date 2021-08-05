#' Parse a listing_detail html dump into a dataframe
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
