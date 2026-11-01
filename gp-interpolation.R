Rcpp::sourceCpp("gp-interpolation.cpp")

# Small dense-reference check; all grid indices passed to C++ are zero-based.
D_test <- 6L
j_test <- c(1L, 3L, 6L)
y_test <- c(0.2, -0.1, 0.7)
L <- matrix(0, D_test - 2L, D_test)
for (i in seq_len(D_test - 2L)) L[i, i:(i + 2L)] <- c(-0.5, 1, -0.5)
A <- diag(D_test)[j_test, , drop = FALSE]
Q <- 10 * crossprod(L) + crossprod(A) / 0.2
covariance <- solve(Q)
mu <- solve(Q, crossprod(A, y_test) / 0.2)
check <- gpFitting(j_test - 1L, y_test, 10, 0.2, D_test)
mean_error <- max(abs(check[, 1L] - as.vector(mu)))
sd_error <- max(abs(check[, 2L] - sqrt(diag(covariance))))
stopifnot(identical(dim(check), c(D_test, 2L)), all(is.finite(check)),
          all(check[, 2L] >= 0), mean_error < 1e-8, sd_error < 1e-8)
print(c(mean_max_error = mean_error, sd_max_error = sd_error))

set.seed(2026)
D <- 1000L
n <- 100L
sigmaSq_y <- 0.1
sj <- seq(0, 1, length.out = D)
truth <- sin(6 * pi * sj)
jSet <- sort(sample.int(D, n, replace = FALSE))
yVec <- truth[jSet] + rnorm(n, sd = sqrt(sigmaSq_y))
lambda_values <- c(1e6, 1e8)
fits <- lapply(lambda_values, function(lambdaSq) {
    result <- gpFitting(jSet - 1L, yVec, lambdaSq, sigmaSq_y, D)
    stopifnot(identical(dim(result), c(D, 2L)), all(is.finite(result)),
              all(result[, 2L] >= 0))
    result
})
print(data.frame(lambdaSq = lambda_values, D = D, observations = n,
                 sigmaSq_y = sigmaSq_y,
                 mse = vapply(fits, function(fit) {
                     mean((fit[, 1L] - truth)^2)
                 }, numeric(1))))

pdf("gp-figure.pdf", width = 10, height = 8)

old_par <- par(mfrow = c(length(fits), 1), mar = c(4, 4, 3, 1))
for (i in seq_along(fits)) {
    fit <- fits[[i]]
    lower <- fit[, 1L] - fit[, 2L]
    upper <- fit[, 1L] + fit[, 2L]
    plot(sj, truth, type = "n", ylim = range(truth, yVec, lower, upper),
         xlab = "s", ylab = "f(s)",
         main = paste("lambdaSq =", lambda_values[i]))
    polygon(c(sj, rev(sj)), c(upper, rev(lower)),
            col = "lightgrey", border = NA)
    lines(sj, truth, col = "black", lwd = 2)
    lines(sj, fit[, 1L], col = "red", lwd = 2)
    points(sj[jSet], yVec, pch = 20, cex = 0.5)
    legend("topright", c("True function", "Posterior mean", "Mean +/- 1 SD"),
           col = c("black", "red", "lightgrey"), lwd = c(2, 2, 6), bty = "n")
}
par(old_par)
dev.off()
