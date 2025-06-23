%% main.m - 主实验文件
% MATLAB隐写实验：F4和F5算法实现
% 包含信息嵌入、检测、矩阵编码比较和混洗技术分析

% 1. 准备实验数据
fprintf('=== 隐写实验开始 ===\n');

carrier_image = imread('house.jpg');
if size(carrier_image, 3) == 3
	carrier_image = rgb2gray(carrier_image);
end
carrier_image = double(carrier_image);

% 生成3KB测试文本数据
secret_text = generate_secret_data();
secret_bits = text_to_bits(secret_text);
fprintf('生成秘密信息长度: %d bits (约%.2f KB)\n', length(secret_bits), length(secret_bits)/8/1024);

% 2. 执行各个任务
fprintf('\n=== 执行Task 1: F4隐写系统 ===\n');
task1_results = task1(carrier_image, secret_bits);

fprintf('\n=== 执行Task 2: F5隐写系统 ===\n');
task2_results = task2(carrier_image, secret_bits);

fprintf('\n=== 执行Task 3: F5混洗技术 ===\n');
task3_results = task3(carrier_image, secret_bits);

% 3. 综合分析和可视化
fprintf('\n=== 综合分析 ===\n');
analyze_results(carrier_image, task1_results, task2_results, task3_results);

fprintf('\n=== 实验完成 ===\n');