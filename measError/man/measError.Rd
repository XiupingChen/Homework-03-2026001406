\name{getData}
\alias{getData}
\alias{naiveRegression}
\alias{correctedRegression}
\title{Simulate a measurement-error regression and estimate coefficients}
\description{Generate one sample and compare naive least squares with an instrumental-variable correction using a second independent proxy.}
\usage{
getData(n, beta0, beta1, sigmaE, sigmaU, sigmaQ)
naiveRegression(data)
correctedRegression(data)
}
\arguments{
\item{n}{Number of observations (at least 3).}
\item{beta0}{True intercept.}
\item{beta1}{True slope.}
\item{sigmaE}{Standard deviation of outcome error.}
\item{sigmaU}{Length-n vector of measurement-error standard deviations for W.}
\item{sigmaQ}{Length-n vector of measurement-error standard deviations for Q.}
\item{data}{Data frame returned by getData, or one with columns W, Q and Y.}
}
\details{The simulated model is X ~ N(0, 1), W = X + U, Q = X + V, and Y = beta0 + beta1 X + E. U, V and E are independent zero-mean Gaussian errors. The corrected slope is cov(Q,Y)/cov(Q,W), and the intercept is mean(Y) minus slope times mean(W).}
\value{getData returns a data frame with X, W, Q and Y; the regressions return named numeric vectors (intercept, slope).}
\examples{
set.seed(1)
d <- getData(10, 1, 2, 0.2, rep(0.5, 10), rep(0.15, 10))
naiveRegression(d)
correctedRegression(d)
}
