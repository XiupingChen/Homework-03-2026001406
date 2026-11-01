Rcpp::sourceCpp("low-rank-approx.cpp")
source("image-utils.R")

# R SVD is only a reference for testing, not the required implementation.
referenceApprox <- function(A, K) {
    fit <- svd(A, nu = K, nv = K)
    keep <- seq_len(K)
    raw <- sweep(fit$u[, keep, drop = FALSE], 2L, fit$d[keep], "*") %*%
        t(fit$v[, keep, drop = FALSE])
    pmin(pmax(raw, 0), 1)
}

cases <- list(
    diagonal = diag(c(0.9, 0.5, 0.2)),
    rectangular = matrix(c(0.1, 0.4, 0.7, 0.8, 0.2, 0.5), 3L, 2L),
    single = matrix(0.6, 1L, 1L)
)
for (name in names(cases)) {
    A <- cases[[name]]
    for (K in unique(c(1L, min(dim(A))))) {
        result <- fixedRankApprox(A, K)
        error <- max(abs(result - referenceApprox(A, K)))
        stopifnot(identical(dim(result), dim(A)), all(is.finite(result)),
                  all(result >= 0 & result <= 1), error < 1e-8)
        if (K == min(dim(A))) stopifnot(max(abs(result - A)) < 1e-8)
        cat(name, "K =", K, "maximum absolute error =", error, "\n")
    }
}
set.seed(17)
extra <- matrix(runif(35), 5L, 7L)
for (K in c(1L, 3L, 5L)) {
    result <- fixedRankApprox(extra, K)
    error <- max(abs(result - referenceApprox(extra, K)))
    stopifnot(error < 1e-8)
    cat("random rectangular K =", K, "maximum absolute error =", error, "\n")
}

img <- loadImage(max_size = 512L)
ranks <- c(5L, 20L, 50L)
results <- lapply(ranks, function(K) fixedRankApprox(img, K))
errors <- vapply(results, function(result) {
    norm(img - result, "F") / norm(img, "F")
}, numeric(1))
print(data.frame(K = ranks, relative_frobenius_error = errors,
                 factor_storage_ratio = ranks * (sum(dim(img)) + 1) / length(img),
                 rows = nrow(img), cols = ncol(img)))

pdf("low-rank-figure.pdf", width = 10, height = 8)

old_par <- par(mfrow = c(2, 2), mar = c(1, 1, 3, 1))
drawImage(img, "Original")
for (i in seq_along(ranks)) drawImage(results[[i]], paste("K =", ranks[i]))
par(old_par)
dev.off()
