# Homework 3

本次作业共包含四个部分，分别涉及低秩矩阵近似、高斯过程插值、测量误差回归和 OpenMP 图像卷积。使用 R 和 C++ 完成相关算法实现，并通过数值实验、结果对比和可视化检验实现效果。

## 1. Low-Rank Approximation

利用奇异值分解（SVD）实现矩阵低秩近似，并将其应用于图像压缩与重构。通过保留不同数量的奇异值，比较不同秩下的图像重构效果及相对误差。

主要文件：
- `low-rank-approx.R`
- `low-rank-approx.cpp`
- `image-utils.R`
- `low-rank-figure.pdf`

## 2. Gaussian Process Interpolation

实现高斯过程插值，利用稀疏矩阵求解方法完成计算，并通过不同平滑参数下的实验，比较后验均值及其不确定性变化。

主要文件：
- `gp-interpolation.R`
- `gp-interpolation.cpp`
- `gp-figure.pdf`

## 3. Measurement Error Regression

通过模拟实验研究测量误差对回归估计的影响，比较朴素回归与校正回归的估计效果，并进一步考察串行和并行计算的结果一致性及运行效率。

主要文件：
- `measurement-error-simulation.R`
- `measError/`
- `measurement-error-figure.pdf`

## 4. Image Convolution with OpenMP

使用 C++ 和 OpenMP 实现图像卷积的并行计算，完成高斯平滑、图像锐化和边缘检测等操作。通过比较串行与并行计算结果，检验计算正确性，并分析不同线程数量下的运行时间和加速效果。

主要文件：
- `image-convolution-openmp.R`
- `image-convolution-openmp.cpp`
- `image-utils.R`
- `assets/`
- `convolution-figure.pdf`

## AI Tool Usage

在作业完成过程中，使用 ChatGPT 辅助进行部分代码理解、问题排查和文档整理。代码均经过实际运行，并对实验输出结果进行了检查。
