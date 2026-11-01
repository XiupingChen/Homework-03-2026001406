#include <RcppArmadillo.h>
#include <algorithm>
#ifdef _OPENMP
#include <omp.h>
#endif
// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::plugins(cpp11)]]
// [[Rcpp::plugins(openmp)]]

int mirrorIndex(int index, int length) {
    if (index < 0) return -index - 1;
    if (index >= length) return 2 * length - index - 1;
    return index;
}

void validateInputs(const arma::mat& img, const arma::mat& kernel) {
    if (img.n_rows == 0 || img.n_cols == 0 || !img.is_finite() ||
        kernel.n_rows != 3 || kernel.n_cols != 3 || !kernel.is_finite()) {
        Rcpp::stop("Use a nonempty finite image and a finite 3-by-3 kernel.");
    }
}

// [[Rcpp::export]]
bool openmpAvailable() {
#ifdef _OPENMP
    return true;
#else
    return false;
#endif
}

// Provided serial baseline: do not modify its boundary or clipping rules.
// [[Rcpp::export]]
arma::mat imageConvSerial(const arma::mat& img, const arma::mat& kernel) {
    validateInputs(img, kernel);
    const int rows = img.n_rows;
    const int cols = img.n_cols;
    arma::mat result(rows, cols);
    for (int j = 0; j < cols; ++j) {
        for (int i = 0; i < rows; ++i) {
            double value = 0.0;
            for (int a = -1; a <= 1; ++a) {
                for (int b = -1; b <= 1; ++b) {
                    value += img(mirrorIndex(i + a, rows),
                                 mirrorIndex(j + b, cols)) * kernel(a + 1, b + 1);
                }
            }
            result(i, j) = std::max(0.0, std::min(1.0, value));
        }
    }
    return result;
}

// [[Rcpp::export]]
arma::mat imageConvParallel(const arma::mat& img, const arma::mat& kernel,
                            int threads) {
    validateInputs(img, kernel);
    if (threads < 1) Rcpp::stop("threads must be positive.");
#ifndef _OPENMP
    Rcpp::stop("OpenMP is not enabled; configure your compiler first.");
#endif
    const int rows = static_cast<int>(img.n_rows);
    const int cols = static_cast<int>(img.n_cols);
    arma::mat result(rows, cols);
#ifdef _OPENMP
#pragma omp parallel for num_threads(threads) schedule(static)
    for (int j = 0; j < cols; ++j) {
        for (int i = 0; i < rows; ++i) {
            double value = 0.0;
            for (int a = -1; a <= 1; ++a) {
                for (int b = -1; b <= 1; ++b) {
                    value += img(mirrorIndex(i + a, rows),
                                 mirrorIndex(j + b, cols)) * kernel(a + 1, b + 1);
                }
            }
            result(i, j) = std::max(0.0, std::min(1.0, value));
        }
    }
#endif
    return result;
}
