# Generated-style wrappers; changes to C++ signatures need matching updates here.
getData <- function(n, beta0, beta1, sigmaE, sigmaU, sigmaQ) {
    .Call(`_measError_getData`, n, beta0, beta1, sigmaE, sigmaU, sigmaQ)
}
naiveRegression <- function(data) {
    .Call(`_measError_naiveRegression`, data)
}
correctedRegression <- function(data) {
    .Call(`_measError_correctedRegression`, data)
}
