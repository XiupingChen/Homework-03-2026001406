# Homework 3

四道题的 R、C++ 源码与图片均放在本目录；第 3 题的包在 `measError/`。
运行时先进入本目录，不要从 `starter-code/` 启动。

## 环境与安装

需要 R（建议 4.3+）、支持 C++11 的编译器，以及 Rcpp、RcppEigen、RcppArmadillo、jpeg、foreach、doRNG、doParallel。第 4 题还需要 OpenMP 编译支持（macOS 默认 Apple Clang 通常不支持，须另行配置）。

在 R 控制台安装依赖：

```r
install.packages(c("Rcpp", "RcppEigen", "RcppArmadillo", "jpeg",
                   "foreach", "doRNG", "doParallel"))
```

在终端安装自建包，再从提交目录运行脚本：

```bash
R CMD INSTALL measError
Rscript low-rank-approx.R
Rscript gp-interpolation.R
Rscript measurement-error-simulation.R
Rscript image-convolution-openmp.R
```

包自带小测试可单独运行：`Rscript measError/tests/smoke.R`。每道题的脚本都会输出检查与指标，图像另存成 `*-figure.pdf`；这些是运行时生成文件，不需要放进提交压缩包。

记录本机版本（运行后将结果填进报告）：

```bash
Rscript -e 'cat(R.version.string,"\n"); for(p in c("Rcpp","RcppEigen","RcppArmadillo")) cat(p, as.character(packageVersion(p)),"\n"); cat(Sys.info()[c("sysname","release","machine")],"\n")'
R CMD config CXX11
R CMD config CXX11FLAGS
```

## 实现与检查

第 1 题由 Eigen 的薄 SVD 重构前 K 项并截断像素；与 R 的 `svd` 结果比较。第 2 题保留给定的稀疏矩阵求解程序和小规模稠密对照；同组观测比较两个平滑参数。第 3 题用两个独立的带噪代理变量 W、Q 模拟测量误差：朴素回归为 Y 对 W 的最小二乘，校正回归以 Q 为 W 的工具变量；doRNG 给串行、并行分配相同任务级随机流。第 4 题用 OpenMP 对输出列并行，每个像素由一个线程写入，与串行版本逐像素比较。

第 3 题的具体模型与函数接口按本包帮助页 `?getData` 定义；如果课堂提供了不同的 `measError` 原始源码，应以课件版接口为准再调整。 

## AI 工具说明

本次使用 ChatGPT 辅助完成第 1、3、4 题的代码与实验脚本，以及第 2 题的说明和报告草稿。第 1、2、4 题以老师给的 starter code 为基础。最终提交前应在本机运行全部测试、核对数字与图像，并如实填写 `report.pdf` 的结果、版本、计时；未运行的结果不能写成已经验证。
