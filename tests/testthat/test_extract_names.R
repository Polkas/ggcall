test_that("extract_names correctly extracts variables and functions", {

  # Test case 1: Simple function with variables
  expr1 <- quote(ggplot(data, aes(x = !!as.name(x), y = !!as.name(y))))
  result1 <- extract_names(expr1)

  # Expected output: "ggplot", "data", "aes", "x", "as.name", "y"
  expected1 <- c("ggplot", "data", "aes", "x", "as.name", "y", "!")
  expect_setequal(result1, expected1)  # Check if result matches the expected set of names

  # Test case 2: More complex ggplot call with multiple functions and variables
  expr2 <- quote(ggplot(data, aes(x = !!as.name(x), y = !!as.name(y))) +
                   geom_point(alpha = 0.4) +
                   facet_grid(~gear) +
                   theme(axis.title.x = element_blank()) +
                   labs(x = "custom xlab"))
  result2 <- extract_names(expr2)

  # Expected output
  expected2 <- c("ggplot", "data", "aes", "x", "as.name", "y", "geom_point",
                 "facet_grid", "gear", "theme", "element_blank", "labs", "+", "!", "~")
  expect_setequal(result2, expected2)  # Check if result matches the expected set

  # Test case 3: Empty input
  expr3 <- NULL
  result3 <- extract_names(expr3)

  # Expected output: empty vector
  expect_equal(result3, character())

  # Test case 4: Expression with only variables
  expr4 <- quote(a + b + c)
  result4 <- extract_names(expr4)

  # Expected output: "a", "b", "c", "+"
  expected4 <- c("a", "b", "c", "+")
  expect_setequal(result4, expected4)  # Ensure the + operator is recognized

  # Test case 5: Function without arguments
  expr5 <- quote(print())
  result5 <- extract_names(expr5)

  # Expected output: "print"
  expect_equal(result5, "print")

  # Test case 6: Non-standard calls like operators
  expr6 <- quote(a * b / c + d)
  result6 <- extract_names(expr6)

  # Expected output: "a", "b", "c", "d", "*", "/", "+"
  expected6 <- c("a", "b", "c", "d", "*", "/", "+")
  expect_setequal(result6, expected6)  # Check if the result is correct

})
