library(measError)
set.seed(19)
n <- 50L
d <- getData(n, 1, 2, 0, rep(0, n), rep(0, n))
stopifnot(nrow(d) == n,
          max(abs(naiveRegression(d) - c(intercept = 1, slope = 2))) < 1e-10,
          max(abs(correctedRegression(d) - c(intercept = 1, slope = 2))) < 1e-10)
cat("measError smoke test: PASS\n")
