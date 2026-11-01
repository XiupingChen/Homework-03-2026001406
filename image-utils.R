# Run the assignment scripts from the directory containing these files.
loadImage <- function(path = "assets/image.jpg", max_size = 512L) {
    if (!file.exists(path)) stop("Image not found: ", path)
    if (!requireNamespace("jpeg", quietly = TRUE)) {
        stop("Install the R package 'jpeg' before reading the assignment image.")
    }
    img <- jpeg::readJPEG(path)
    if (length(dim(img)) == 3L) {
        img <- 0.299 * img[, , 1L] + 0.587 * img[, , 2L] +
            0.114 * img[, , 3L]
    }
    stride <- max(1L, ceiling(max(dim(img)) / max_size))
    img <- img[seq.int(1L, nrow(img), by = stride),
               seq.int(1L, ncol(img), by = stride), drop = FALSE]
    img
}

drawImage <- function(values, title) {
    plot.new()
    plot.window(xlim = c(0, ncol(values)), ylim = c(0, nrow(values)), asp = 1)
    rasterImage(as.raster(values), 0, 0, ncol(values), nrow(values),
                interpolate = FALSE)
    title(main = title)
}

# Batch calls to avoid reporting zero elapsed time for a fast function.
# Compilation, image loading, validation and drawing stay outside this helper.
measureTime <- function(fun, min_seconds = 0.2, repetitions = 3L) {
    invisible(fun())
    batch <- 1L
    repeat {
        elapsed <- system.time(for (i in seq_len(batch)) fun())[["elapsed"]]
        if (elapsed >= min_seconds || batch >= 4096L) break
        batch <- batch * 2L
    }
    seconds <- replicate(repetitions, {
        system.time(for (i in seq_len(batch)) fun())[["elapsed"]] / batch
    })
    list(seconds = median(seconds), calls_per_batch = batch,
         repetitions = repetitions)
}
