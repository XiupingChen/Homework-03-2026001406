#include <RcppEigen.h>
#include <vector>
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::plugins(cpp11)]]

typedef Eigen::SparseMatrix<double> SpMat;
typedef Eigen::Triplet<double> Triplet;

// Provided lecture example: no TODO is required in this file.
SpMat createLmat(int D) {
    SpMat L(D - 2, D);
    L.reserve(Eigen::VectorXi::Constant(D, 3));
    for (int j = 0; j < D; ++j) {
        for (int offset = -1; offset <= 1; ++offset) {
            const int row = offset + j - 1;
            if (row < 0 || row >= D - 2) continue;
            L.insert(row, j) = (offset == 0) ? 1.0 : -0.5;
        }
    }
    L.makeCompressed();
    return L;
}

SpMat createAmat(const Eigen::VectorXi& jSet, int D) {
    SpMat A(jSet.size(), D);
    std::vector<Triplet> entries;
    entries.reserve(jSet.size());
    for (int j = 0; j < jSet.size(); ++j) {
        entries.push_back(Triplet(j, jSet(j), 1.0));
    }
    A.setFromTriplets(entries.begin(), entries.end());
    return A;
}

// jSet contains zero-based grid indices. lambdaSq is lambda squared;
// sigmaSq_y is the observation noise variance.
// [[Rcpp::export]]
Eigen::MatrixXd gpFitting(Eigen::VectorXi jSet, Eigen::VectorXd yVec,
                          double lambdaSq, double sigmaSq_y, int D) {
    if (D < 3 || jSet.size() < 2 || jSet.size() != yVec.size() ||
        !yVec.allFinite() || !std::isfinite(lambdaSq) || lambdaSq <= 0 ||
        !std::isfinite(sigmaSq_y) || sigmaSq_y <= 0) {
        Rcpp::stop("Invalid dimensions, observations, or variance parameters.");
    }
    if (jSet.minCoeff() < 0 || jSet.maxCoeff() >= D ||
        jSet.minCoeff() == jSet.maxCoeff()) {
        Rcpp::stop("Observe at least two distinct valid grid locations.");
    }
    const SpMat L = createLmat(D);
    const SpMat A = createAmat(jSet, D);
    const SpMat Q = lambdaSq * (L.transpose() * L) +
        (A.transpose() * A) / sigmaSq_y;
    Eigen::SimplicialLLT<SpMat> solver;
    solver.compute(Q);
    if (solver.info() != Eigen::Success) Rcpp::stop("Factorization failed.");

    const Eigen::VectorXd rhs = (A.transpose() * yVec) / sigmaSq_y;
    const Eigen::VectorXd mu = solver.solve(rhs);
    if (solver.info() != Eigen::Success) Rcpp::stop("Mean solve failed.");
    const Eigen::MatrixXd identity = Eigen::MatrixXd::Identity(D, D);
    const Eigen::MatrixXd covariance = solver.solve(identity);
    if (solver.info() != Eigen::Success || !mu.allFinite() ||
        !covariance.allFinite()) Rcpp::stop("Covariance solve failed.");
    const Eigen::VectorXd variance = covariance.diagonal();
    if (variance.minCoeff() < -1e-8) Rcpp::stop("Negative posterior variance.");

    Eigen::MatrixXd result(D, 2);
    result.col(0) = mu;
    result.col(1) = variance.cwiseMax(0.0).cwiseSqrt();
    return result;
}
