#' Asynchronously save an webpage as a HTML Document
#'
#' This is a working function to asynchronously receive DOM objects
#'
#' @param url the url to scrape
#' @param folder the target folder to dump the html files
#' @param element_class the name of a class that the script will wait until loaded.
#'
#' @return a promise of the scraped page
#' @export
async_save_as_html <- function(url,folder,element_class=NA) {
  function(client) {
    Page <- client$Page
    Runtime <- client$Runtime

    Page$enable() %...>% {
      Page$navigate(url = url)
    } %...>% {
      Page$loadEventFired()
    } %...>% {
      Sys.sleep(0.2)
    } %...>% {
      Runtime$evaluate(
        expression = 'document.documentElement.outerHTML')
    } %...>% (function(result) {
      html <- result$result$value
      cat(html, "\n", file = paste0(folder,"/",
                                    Sys.time()%>%as.numeric(),"_",
                                    httr::parse_url(tolower(url))$hostname%>%
                                    stringr::str_replace_all("\\.","_")%>%
                                    stringr::str_replace("www_",""),
                                    ifelse(is.na(httr::parse_url(url)$query$strana),"",paste0("_strana_",httr::parse_url(url)$query$strana)),
                                    ".html"))})
  }}



#' Dump HTML files of a list of webpages
#'
#'uses a headless chrome browser to render a list of urls and dump them as html files to a selected folder
#'
#' @param ... a character list of urls to scrape
#' @param output_dir the output directory folder where to dump the html files
#'
#' @return a directory of scraped html files
#' @export
#'
#' @examples
#' \dontrun{save_as_html("https://test.com", "https://google.com",output_dir = "dump")}
save_as_html <- function(...,output_dir=".") {

  #check if the directory exists if not create it

  if (!dir.exists(output_dir)) dir.create(output_dir)

  list(...) %>% unlist %>%
    purrr::map(async_save_as_html, folder=output_dir) %>%
    crrri::perform_with_chrome(.list = .,extra_args = c('--blink-settings=imagesEnabled=false'))
}


#' Dump a single url as HTML
#'
#' @param url url to be scraped
#' @param element_class the name of a class that the script will wait until loaded.
#'
#' @return a html text
#' @export
dump_DOM <- function(url,element_class=NA) {
  crrri::perform_with_chrome(extra_args = c('--blink-settings=imagesEnabled=false'),function(client) {
    Network <- client$Network
    Page <- client$Page
    Runtime <- client$Runtime
    Network$enable() %...>% {
      Page$enable()
    } %...>% {
      Network$setCacheDisabled(cacheDisabled = TRUE)
    } %...>% {
      Page$navigate(url = url)
    } %...>% {
      Page$loadEventFired()
    } %...>% {
      Sys.sleep(0.2)
    } %...>% {
      Runtime$evaluate(
        expression = 'document.documentElement.outerHTML'
      )
    } %...>% (function(result) {
      html <- result$result$value
      #cat(html, "\n")
    })
  })
}
