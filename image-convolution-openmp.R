Rcpp::sourceCpp("image-convolution-openmp.cpp")
source("image-utils.R")
if (!openmpAvailable()) {
    stop("OpenMP is not enabled. Configure an OpenMP-capable compiler first.")
}

kernels <- list(
    gaussian = matrix(c(1, 2, 1, 2, 4, 2, 1, 2, 1), 3, 3) / 16,
    sharpen = matrix(c(0, -1, 0, -1, 5, -1, 0, -1, 0), 3, 3),
    edge = matrix(c(-1, -1, -1, -1, 8, -1, -1, -1, -1), 3, 3)
)
thread_counts <- c(1L, 2L, 4L) # Adjust for your machine; keep at least two values.

# Include single-row and single-column inputs to check boundary handling.
set.seed(2026)
test_images <- list(matrix(0.5, 1L, 1L), matrix(c(0.1, 0.8, 0.3), 1L, 3L),
                    matrix(c(0.1, 0.8, 0.3), 3L, 1L), matrix(runif(20), 4L, 5L))
for (img in test_images) {
    for (kernel in kernels) {
        serial <- imageConvSerial(img, kernel)
        for (threads in thread_counts) {
            result <- imageConvParallel(img, kernel, threads)
            stopifnot(identical(dim(result), dim(img)), all(is.finite(result)),
                      all(result >= 0 & result <= 1),
                      max(abs(serial - result)) < 1e-10)
        }
    }
}

img <- loadImage(max_size = 1024L)
results <- lapply(kernels, function(kernel) {
    serial <- imageConvSerial(img, kernel)
    parallel <- imageConvParallel(img, kernel, max(thread_counts))
    error <- max(abs(serial - parallel))
    stopifnot(error < 1e-10)
    cat("Maximum serial/parallel difference:", error, "\n")
    parallel
})

kernel <- kernels$gaussian
serial_time <- measureTime(function() imageConvSerial(img, kernel))
parallel_times <- lapply(thread_counts, function(threads) {
    measureTime(function() imageConvParallel(img, kernel, threads))
})
timings <- c(list(serial_time), parallel_times)
seconds <- vapply(timings, function(x) x$seconds, numeric(1))
print(data.frame(
    method = c("serial", rep("OpenMP", length(thread_counts))),
    threads = c(1L, thread_counts), seconds = seconds,
    speedup = serial_time$seconds / seconds,
    calls_per_batch = vapply(timings, function(x) x$calls_per_batch, integer(1)),
    repetitions = vapply(timings, function(x) x$repetitions, integer(1)),
    rows = nrow(img), cols = ncol(img)
))

pdf("convolution-figure.pdf", width = 10, height = 8)
old_par <- par(mfrow = c(2, 2), mar = c(1, 1, 3, 1))
drawImage(img, "Original")
for (name in names(results)) drawImage(results[[name]], name)
par(old_par)
dev.off()
