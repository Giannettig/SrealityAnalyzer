test_that("the scraper works without a specified directory", {
  expect_error(save_as_html("https://test.com", "https://google.com"),NA)
})

test_that("the scraper creates a direcotry if specified and nonexisting", {
  expect_error(save_as_html("https://test.com", output_dir="dump"),NA)
  unlink("dump", recursive = TRUE)
})
