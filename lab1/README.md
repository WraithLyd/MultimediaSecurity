# README

## 文件构成

在主文件夹下存在5个子文件夹

* `./code` 存储matlab代码和函数文件
  * `./code/D_LC.m` 为D_LC算法函数文件
  * `./code/E_blind.m` 为E_blind算法函数文件
  * `./code/False_pn.m` 为计算False Positive/Negative Rate的函数文件
  * `./code/generate.m` 为后续实验生成随机水印的文件
  * `./code/task1.m` 使用水印测试 E_BLIND/D_LC 系统应用于不同封面
  * `./code/task2.m` 使用不同水印测试 E_BLIND/D_LC 系统应用于同一封面（黑白像素比例不高于30%）
  * `./code/task3.m` 使用不同水印测试 E_BLIND/D_LC 系统应用于同一封面（黑白像素比例不低于50%）
  * `./code/task4.m` 在避免了8-bit灰度截断情况下，使用不同水印测试 E_BLIND/D_LC 系统应用于同一封面（黑白像素比例不低于50%）
* `./data` 存储实验提供的标准数据集
* `./task1_data` 为 `./code/task1.m` 使用的水印
* `./task2_data` 为 `./code/task2.m` 使用的水印
* `./task3_data` 为 `./code/task3.m` 和 `./code/task3.m` 使用的水印

## 执行

```
generate.m
task1.m
task2.m
task3.m
task4.m
```

注意在本层路径上执行，并将`./code`添加到MATLAB路径中

