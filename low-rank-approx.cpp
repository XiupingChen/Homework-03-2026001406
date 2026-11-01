#include <RcppEigen.h>
#include <algorithm>
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::plugins(cpp11)]]

// [[Rcpp::export]]
Eigen::MatrixXd fixedRankApprox(Eigen::MatrixXd A, int K) {
    if (A.rows() == 0 || A.cols() == 0 || !A.allFinite()) {
        Rcpp::stop("A must be a nonempty finite matrix.");
    }
    if (K < 1 || K > std::min(A.rows(), A.cols())) {
        Rcpp::stop("K must be between 1 and min(nrow(A), ncol(A)).");
    }
    Eigen::JacobiSVD<Eigen::MatrixXd> svd(
        A, Eigen::ComputeThinU | Eigen::ComputeThinV);
    Eigen::MatrixXd result = svd.matrixU().leftCols(K) *
        svd.singularValues().head(K).asDiagonal() *
        svd.matrixV().leftCols(K).transpose();
    return result.cwiseMax(0.0).cwiseMin(1.0);
}
