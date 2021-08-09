#' Parsing function for asynchronous scraping of listing details
#'
#' This function is to be used exclusively with the crrri::perform_with_chrome function
#'
#' @param sreality_detail_url The url to parse
#'
#' @return CRRRI Promise
#' @export
async_get_sreality_detail <- function(sreality_detail_url) {
  function(client) {
    Page <- client$Page
    Runtime <- client$Runtime
    Page$enable() %...>% {
      Page$navigate(url = sreality_detail_url)
    } %...>% {
      Page$loadEventFired()
    } %...>% {
      Sys.sleep(0.2)
    } %...>% {
      Runtime$evaluate(expression = 'document.documentElement.outerHTML')
    } %...>% (function(result) {
      res<-parse_flat_detail(result$result$value)

      if(nrow(res)==0) {

        Page$enable() %...>% {
        Page$navigate(url = sreality_detail_url)
       }%...>% {
         Page$loadEventFired()
       } %...>% {
         Sys.sleep(1)
       } %...>% {
        logger<-log4r::logger("DEBUG", appenders = (log4r::console_appender()))
        log4r::debug(logger, paste("Retrying link",sreality_detail_url))
      } %...>% {
        Runtime$evaluate(expression = 'document.documentElement.outerHTML')
      } %...>% (function(result) {
        res<-parse_flat_detail(result$result$value) })
} else return(res)

    })

  }
}

#' Parsing function for asynchronous scraping of pagination
#'
#' This function is to be used exclusively with the crrri::perform_with_chrome function
#'
#' @param sreality_pagination_url The url to parse
#'
#' @return CRRRI Promise
#' @export
async_get_sreality_pagination <- function(sreality_pagination_url) {
  function(client) {
    Page <- client$Page
    Runtime <- client$Runtime
    Page$enable() %...>% {
      Page$navigate(url = sreality_pagination_url)
    } %...>% {
      Page$loadEventFired()
    } %...>% {
      Sys.sleep(0.2)
    } %...>% {
      Runtime$evaluate(expression = 'document.documentElement.outerHTML')
    } %...>% (function(result) {
      res<-get_page_info(result$result$value)

      if(nrow(res)==0) {

        Page$enable() %...>% {
          Page$navigate(url = sreality_pagination_url)
        }%...>% {
          Page$loadEventFired()
        } %...>% {
          Sys.sleep(1)
        } %...>% {
          logger<-log4r::logger("DEBUG", appenders = (log4r::console_appender()))
          log4r::debug(logger, paste("Retrying link",sreality_pagination_url))
        } %...>% {
          Runtime$evaluate(expression = 'document.documentElement.outerHTML')
        } %...>% (function(result) {
          res<-get_page_info(result$result$value) })
      } else return(res)

    })

  }
}



