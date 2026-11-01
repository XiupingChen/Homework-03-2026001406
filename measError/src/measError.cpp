#include <Rcpp.h>
#include <cmath>
using namespace Rcpp;

// X ~ N(0,1); W and Q are independent noisy measurements of X.
// Y = beta0 + beta1 X + E. Each sigma vector contains standard deviations.
// [[Rcpp::export]]
DataFrame getData(int n, double beta0, double beta1, double sigmaE,
                  NumericVector sigmaU, NumericVector sigmaQ) {
    if (n < 3 || sigmaE < 0 || !std::isfinite(sigmaE) ||
        !std::isfinite(beta0) || !std::isfinite(beta1) ||
        sigmaU.size() != n || sigmaQ.size() != n) {
        stop("Invalid sample size or parameters.");
    }
    for (int i = 0; i < n; ++i) {
        if (!std::isfinite(sigmaU[i]) || sigmaU[i] < 0 ||
            !std::isfinite(sigmaQ[i]) || sigmaQ[i] < 0)
            stop("Measurement-error standard deviations must be finite and nonnegative.");
    }
    RNGScope scope;
    NumericVector X(n), W(n), Q(n), Y(n);
    for (int i = 0; i < n; ++i) {
        X[i] = R::rnorm(0.0, 1.0);
        W[i] = X[i] + R::rnorm(0.0, sigmaU[i]);
        Q[i] = X[i] + R::rnorm(0.0, sigmaQ[i]);
        Y[i] = beta0 + beta1 * X[i] + R::rnorm(0.0, sigmaE);
    }
    return DataFrame::create(_["X"] = X, _["W"] = W,
                             _["Q"] = Q, _["Y"] = Y);
}

// [[Rcpp::export]]
NumericVector naiveRegression(DataFrame data) {
    NumericVector W = data["W"], Y = data["Y"];
    int n = W.size();
    if (n < 3 || Y.size() != n) stop("Data must have matching W and Y columns.");
    double mw = 0, my = 0, sww = 0, swy = 0;
    for (int i = 0; i < n; ++i) {
        if (!std::isfinite(W[i]) || !std::isfinite(Y[i])) stop("Non-finite data.");
        mw += W[i]; my += Y[i];
    }
    mw /= n; my /= n;
    for (int i = 0; i < n; ++i) {
        sww += (W[i] - mw) * (W[i] - mw);
        swy += (W[i] - mw) * (Y[i] - my);
    }
    if (sww <= 0) stop("W has zero variance.");
    double slope = swy / sww;
    return NumericVector::create(_["intercept"] = my - slope * mw,
                                 _["slope"] = slope);
}

// Q is an independent noisy proxy for X, used as an instrument for W.
// [[Rcpp::export]]
NumericVector correctedRegression(DataFrame data) {
    NumericVector W = data["W"], Q = data["Q"], Y = data["Y"];
    int n = W.size();
    if (n < 3 || Q.size() != n || Y.size() != n)
        stop("Data must have matching W, Q and Y columns.");
    double mw = 0, mq = 0, my = 0, sqw = 0, sqy = 0;
    for (int i = 0; i < n; ++i) {
        if (!std::isfinite(W[i]) || !std::isfinite(Q[i]) ||
            !std::isfinite(Y[i])) stop("Non-finite data.");
        mw += W[i]; mq += Q[i]; my += Y[i];
    }
    mw /= n; mq /= n; my /= n;
    for (int i = 0; i < n; ++i) {
        sqw += (Q[i] - mq) * (W[i] - mw);
        sqy += (Q[i] - mq) * (Y[i] - my);
    }
    if (std::abs(sqw) < 1e-12) stop("Instrument has near-zero covariance with W.");
    double slope = sqy / sqw;
    return NumericVector::create(_["intercept"] = my - slope * mw,
                                 _["slope"] = slope);
}
