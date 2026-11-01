library(measError)
library(foreach)
library(doRNG)

n <- 400L
B <- 1000L
beta_true <- c(intercept = 1, slope = 2)
sigmaE <- 0.2
set.seed(20261031)
sigmaU <- runif(n, 0.4, 0.6)
sigmaQ <- runif(n, 0.1, 0.2)
seed <- 20261031L

# Both backends use doRNG's same task-level streams, independent of workers.
simulate_one <- function() {
    d <- getData(n, beta_true[1L], beta_true[2L], sigmaE, sigmaU, sigmaQ)
    c(naive = sqrt(sum((naiveRegression(d) - beta_true)^2)),
      corrected = sqrt(sum((correctedRegression(d) - beta_true)^2)))
}

`%dorng%` <- doRNG::`%dorng%`
run_tasks <- function() {
    foreach(i = seq_len(B),
            .packages = "measError",
            .export = c("simulate_one", "n", "beta_true",
                        "sigmaE", "sigmaU", "sigmaQ"),
            .options.RNG = seed) %dorng% simulate_one()
}

# Small deterministic package check before benchmarking.
test <- getData(12L, 1, 2, 0.2, rep(0.5, 12L), rep(0.15, 12L))
stopifnot(nrow(test) == 12L, all(is.finite(naiveRegression(test))),
          all(is.finite(correctedRegression(test))))

foreach::registerDoSEQ()
serial_elapsed <- system.time(serial <- run_tasks())[["elapsed"]]
serial_again <- run_tasks()
stopifnot(identical(serial, serial_again))

available <- parallel::detectCores(logical = TRUE)
if (is.na(available)) available <- 2L
workers <- unique(pmax(1L, pmin(c(1L, 2L, 4L), available)))
if (length(workers) < 2L) {
    stop("Use a machine with at least two worker counts for the timing comparison.")
}

parallel_elapsed <- numeric(length(workers))
for (j in seq_along(workers)) {
    cl <- parallel::makeCluster(workers[j], type = "PSOCK")
    tryCatch({
        parallel::clusterEvalQ(cl, library(measError))
        doParallel::registerDoParallel(cl)
        parallel_elapsed[j] <- system.time(candidate <- run_tasks())[["elapsed"]]
        stopifnot(identical(serial, candidate))
    }, finally = {
        parallel::stopCluster(cl)
        foreach::registerDoSEQ()
    })
}

cat("Reproducibility: serial repeat and all worker counts identical\n")
cat("Simulation n =", n, "B =", B, "sigmaE =", sigmaE, "\n")
print(data.frame(method = c("serial", rep("parallel", length(workers))),
                 workers = c(1L, workers),
                 seconds = c(serial_elapsed, parallel_elapsed),
                 speedup = serial_elapsed / c(serial_elapsed, parallel_elapsed)))
errors <- do.call(rbind, serial)
print(rbind(mean = colMeans(errors), median = apply(errors, 2L, median)))
pdf("measurement-error-figure.pdf", width = 8, height = 6)
boxplot(errors[, "naive"], errors[, "corrected"], names = c("Naive", "Corrected"),
        ylab = "Euclidean coefficient error", main = "Measurement error regression")
dev.off()
