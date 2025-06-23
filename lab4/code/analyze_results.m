%% 分析函数

function analyze_results(original, task1_results, task2_results, task3_results)
	% 综合结果分析和可视化
	
	% 创建图像对比
	figure('Position', [100, 100, 1200, 800]);
	
	subplot(2,3,1);
	imshow(uint8(original)); title('原始图像');
	
	subplot(2,3,2);
	imshow(uint8(task1_results.stego_image)); title('F4隐写结果');
	
	subplot(2,3,3);
	imshow(uint8(task2_results.matrix1.stego)); title('F5隐写结果');
	
	% DCT直方图对比
	subplot(2,3,4);
	% plot(-10:10, task1_results.original_dct, 'b-', 'LineWidth', 1.5); hold on;
	% plot(-10:10, task1_results.stego_dct, 'r--', 'LineWidth', 1.5);
	plot(-5:5, task1_results.original_dct, 'b-', 'LineWidth', 1.5); hold on;
	plot(-5:5, task1_results.stego_dct, 'r--', 'LineWidth', 1.5);
	legend('原始', 'F4隐写后'); title('F4算法DCT系数直方图');
	xlabel('DCT系数值'); ylabel('频次');
	
	subplot(2,3,5);
	plot(-5:5, task2_results.original_dct, 'b-', 'LineWidth', 1.5); hold on;
	plot(-5:5, task2_results.matrix1.dct, 'r--', 'LineWidth', 1.5);
	% plot(-10:10, task2_results.original_dct, 'b-', 'LineWidth', 1.5); hold on;
	% plot(-10:10, task2_results.matrix1.dct, 'r--', 'LineWidth', 1.5);
	legend('原始', 'F5隐写后'); title('F5算法DCT系数直方图');
	xlabel('DCT系数值'); ylabel('频次');
	
	% 混洗技术对比
	subplot(2,3,6);
	bar([task3_results.no_shuffle.security, task3_results.with_shuffle.security]);
	set(gca, 'XTickLabel', {'无混洗', '混洗'});
	title('混洗技术安全性对比'); ylabel('安全指标');
	
	% 性能比较表格
	fprintf('\n=== 性能比较 ===\n');
	fprintf('算法\t\t成功率(%%)\tPSNR(dB)\t嵌入效率\n');
	fprintf('F4\t\t%.2f\t\t%.2f\t\t-\n', task1_results.success_rate*100, task1_results.psnr);
	fprintf('F5矩阵1\t%.2f\t\t%.2f\t\t%.3f\n', task2_results.matrix1.success*100, task2_results.matrix1.psnr, task2_results.matrix1.rate);
	fprintf('F5矩阵2\t%.2f\t\t%.2f\t\t%.3f\n', task2_results.matrix2.success*100, task2_results.matrix2.psnr, task2_results.matrix2.rate);
	fprintf('F5无混洗\t%.2f\t\t%.2f\t\t安全性:%.3f\n', task3_results.no_shuffle.success*100, task3_results.no_shuffle.psnr, task3_results.no_shuffle.security);
	fprintf('F5混洗\t%.2f\t\t%.2f\t\t安全性:%.3f\n', task3_results.with_shuffle.success*100, task3_results.with_shuffle.psnr, task3_results.with_shuffle.security);
	
	% 保存结果
	saveas(gcf, 'steganography_results.png');
	fprintf('\n结果图像已保存为: steganography_results.png\n');
end