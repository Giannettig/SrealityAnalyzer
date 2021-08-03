test_that("we can get the number on listings per query", {
  expect_error(a<-get_sreality_listings("https://www.sreality.cz/hledani/prodej/byty"),NA)
  expect_error(b<-get_sreality_listings("https://www.sreality.cz/hledani/prodej/byty/ustecky-kraj"),NA)
  expect_error(c<-get_sreality_listings("
https://www.sreality.cz/hledani/prodej/byty/decin,litomerice,chomutov?velikost=2%2Bkk,2%2B1,3%2Bkk,3%2B1,4%2B1,4%2Bkk&vlastnictvi=osobni
"),NA)
})

