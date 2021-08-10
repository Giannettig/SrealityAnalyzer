
# Sreality Full Run  ------------------------------------------------------

#Testing parameters

## query<-"https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj?vlastnictvi=osobni&bez-aukce=1"
## scrape_sreality(query,"Ústecký kraj")

#' Title
#'
#' @param query the query of the search on sreality defaults to https://www.sreality.cz/hledani/prodej/byty/
#' @param tag (char) optional - will include a tag into the data if used
#'
#' @return Creates a csv file with the parsed listings and a log file in the specified folder
#' @export
#'
#' @examples \dontrun{scrape_sreality("https://www.sreality.cz/hledani/prodej/byty")}
scrape_sreality<-function(query="https://www.sreality.cz/hledani/prodej/byty?vlastnictvi=osobni&bez-aukce=1",tag=stringr::str_extract(query,"(?<=\\/)[^\\/]+(?=\\?)|(?<=\\/)[^\\/]+$")){

      run_start<-Sys.time() # get start time

      log_file<- paste0("temp/",as.numeric(run_start)%>%ceiling(),"_run.log")
      out_data<- paste0("temp/",as.numeric(run_start)%>%ceiling(),"_sreality_",paste0(tag,"_"),ifelse(stringr::str_detect(query,"pronajem"),"rent",ifelse(stringr::str_detect(query,"prodej"),"sale","other")),".csv")
      dir.create("temp")
      file_logger <- log4r::logger("DEBUG", appenders = list(log4r::console_appender(),log4r::file_appender(log_file)))

      log4r::info(file_logger, paste("Starting scraping query:", query))

      #get number of listings and pagination links
      pagination_links<-tryCatch(get_url_variants(query),
                                    error = function(c) {log4r::error(file_logger, c); log4r::debug(file_logger, paste0("Query: ", query)) },
                                    warning = function(c) log4r::warning(file_logger, c),
                                    message = function(c) log4r::info(file_logger, c)
                                  )

      log4r::info(file_logger, paste("There are",pagination_links$listings,"listings on this query."))

      #scrape the urls of the listings
      pagination_detail<-tryCatch(purrr::map(pagination_links$pages_url,async_get_sreality_pagination) %>%
        crrri::perform_with_chrome(.list = .,extra_args = c('--blink-settings=imagesEnabled=false'))%>%dplyr::bind_rows(),
        error = function(c) {log4r::error(file_logger, c) },
        warning = function(c) log4r::warning(file_logger, c),
        message = function(c) log4r::info(file_logger, c)
      )

      if(purrr::is_empty(pagination_detail)) stop(
        log4r::error(file_logger, "Failed to retrieve pagination")
        )

      links_scraped<-nrow(pagination_detail)

      if(links_scraped==pagination_links$listings){
             log4r::info(file_logger, paste0("Fetched ",links_scraped,"/",pagination_links$listings," links to listing detail"))}else{
             log4r::warn(file_logger, paste0("Fetched ",links_scraped,"/",pagination_links$listings," links to listing detail"))}


      parsed_details<-tryCatch(purrr::map(pagination_detail$url,async_get_sreality_detail) %>%
        crrri::perform_with_chrome(.list = .,extra_args = c('--blink-settings=imagesEnabled=false'))%>%dplyr::bind_rows(),
        error = function(c) {log4r::error(file_logger, c); log4r::debug(file_logger, paste0("Query: ", query)) },
        warning = function(c) log4r::warning(file_logger, c),
        message = function(c) log4r::info(file_logger, c)
      )

      details_scraped<-parsed_details$id%>%unique()%>%length()

      if(details_scraped==pagination_links$listings){
        log4r::info(file_logger, paste0("Fetched ",details_scraped,"/",pagination_links$listings,"listings"))}else{
          log4r::warn(file_logger, paste0("Fetched ",details_scraped,"/",pagination_links$listings," listings"))}

      parsed_details$location<-tag

      readr::write_csv(parsed_details,out_data)

      #now lets export the files to google cloud storage

      #AIzaSyCJwEfDsYFoEFPyWRylTWRl988nmSiZjHM

      run_time <- Sys.time() - run_start # calculate difference
      log4r::info(file_logger, paste("Scrape finished in ", run_time))


}
