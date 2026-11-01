# Homework 3

姓名：陈秀萍  
学号：2026001406

本次作业包括图片低秩压缩、高斯过程插值、R 包构建与并行模拟，以及 OpenMP 图像卷积四个部分。代码使用 R、Rcpp、RcppEigen 和 RcppArmadillo 完成。

## 作业内容

### 1. 图片低秩压缩

使用 RcppEigen 的 `JacobiSVD` 对灰度图像进行奇异值分解，分别计算 \(K=5\)、\(K=20\) 和 \(K=50\) 时的低秩近似，并比较图像质量、相对 Frobenius 误差和存储量。

相关文件：

- `low-rank-approx.cpp`
- `low-rank-approx.R`
- `image-utils.R`

### 2. 高斯过程插值

使用老师提供的 RcppEigen 稀疏矩阵程序完成高斯过程插值。在相同观测数据下，比较 `lambdaSq=1e6` 和 `lambdaSq=1e8` 时的拟合结果，并使用小规模稠密矩阵计算验证后验均值和标准差。

相关文件：

- `gp-interpolation.cpp`
- `gp-interpolation.R`

### 3. R 包构建与并行模拟

构建 `measError` R 包，其中包含 `getData`、`naiveRegression` 和 `correctedRegression` 三个函数。使用固定随机数种子进行 1000 次测量误差模拟，比较朴素估计与校正估计的误差，并比较串行以及不同 worker 数下的运行时间。

相关文件：

- `measError/`
- `measurement-error-simulation.R`

### 4. OpenMP 图像卷积

使用 RcppArmadillo 和 OpenMP 实现图像卷积的并行计算，完成高斯模糊、锐化和边缘检测，并验证串行与并行结果的一致性。实验比较了 1、2 和 4 个线程下的运行时间。

相关文件：

- `image-convolution-openmp.cpp`
- `image-convolution-openmp.R`
- `image-utils.R`

## 文件结构

```text
homework-03-2026001406/
├── README.md
├── report.pdf
├── assets/
│   └── image.jpg
├── measError/
├── low-rank-approx.cpp
├── low-rank-approx.R
├── gp-interpolation.cpp
├── gp-interpolation.R
├── measurement-error-simulation.R
├── image-convolution-openmp.cpp
├── image-convolution-openmp.R
└── image-utils.R
```

## 运行环境

- 操作系统：Ubuntu 24.04.1，ARM64 aarch64
- R：4.6.1
- Rcpp：1.1.2
- RcppEigen：0.3.4.0.2
- RcppArmadillo：[填写实际版本]
- 编译器：GCC 13.3.0
- 并行环境：R 多进程并行和 OpenMP
- 其他 R 包：`jpeg`、`foreach`、`doRNG`、`doParallel`

第四题需要支持 OpenMP 的编译环境。

## 运行方法

首先进入作业目录：

```bash
cd homework-03-2026001406
```

安装第三题的自建 R 包：

```bash
R CMD INSTALL measError
```

进入 R 后，依次运行：

```r
source("low-rank-approx.R")
source("gp-interpolation.R")
source("measurement-error-simulation.R")
source("image-convolution-openmp.R")
```

第一、二和四题的 R 脚本会通过 `Rcpp::sourceCpp()` 自动编译对应的 C++ 文件。第三题需要先通过 `R CMD INSTALL measError` 安装自建包。

实验所用图片位于：

```text
assets/image.jpg
```

各题的实验结果、测试结果、图像和运行时间见 `report.pdf`。

## AI 工具使用说明

本次作业使用 ChatGPT 辅助理解四道题的要求、检查部分代码实现、排查编译和运行过程中遇到的问题，并协助整理 README 和实验报告。所有程序均由本人在实际环境中运行和检查。

第一题通过与 R 的 `svd()` 参考结果比较验证低秩近似；第二题通过小规模稠密矩阵求解验证后验均值和标准差；第三题使用固定随机数流检查串行与并行结果的一致性；第四题通过比较串行与 OpenMP 并行结果验证卷积计算的正确性。
