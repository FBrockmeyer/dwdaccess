test_that("address_to_lonlat() returns object of length two", {
  expect_equal(length(address_to_lonlat("Brandenburger Tor, Berlin")), 2)
})
