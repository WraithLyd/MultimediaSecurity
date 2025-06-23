%% task2.m - F5隐写系统实现
function results = task2(carrier_image, secret_bits)
	fprintf('正在执行F5隐写算法...\n');
	
	% 实现两种不同的矩阵编码
	fprintf('测试矩阵编码方案1 (1,3,1)...\n');
	[stego1, rate1] = f5_embed_matrix(carrier_image, secret_bits, [1,3,1]);
	extracted1 = f5_extract_matrix(stego1, length(secret_bits), [1,3,1]);
	success_rate1 = sum(secret_bits == extracted1) / length(secret_bits);
	
	fprintf('测试矩阵编码方案2 (2,7,1)...\n');
	[stego2, rate2] = f5_embed_matrix(carrier_image, secret_bits, [2,7,1]);
	extracted2 = f5_extract_matrix(stego2, length(secret_bits), [2,7,1]);
	success_rate2 = sum(secret_bits == extracted2) / length(secret_bits);
	
	% DCT分析
	original_dct = dct_analysis(carrier_image);
	stego1_dct = dct_analysis(stego1);
	stego2_dct = dct_analysis(stego2);
	
	results = struct();
	results.method = 'F5';
	results.matrix1 = struct('stego', stego1, 'rate', rate1, 'success', success_rate1, 'dct', stego1_dct, 'psnr', calculate_psnr(carrier_image, stego1));
	results.matrix2 = struct('stego', stego2, 'rate', rate2, 'success', success_rate2, 'dct', stego2_dct, 'psnr', calculate_psnr(carrier_image, stego2));
	results.original_dct = original_dct;
	
	fprintf('F5矩阵编码1 - 嵌入效率: %.3f, 成功率: %.4f%%, PSNR: %.2f dB\n', rate1, success_rate1*100, results.matrix1.psnr);
	fprintf('F5矩阵编码2 - 嵌入效率: %.3f, 成功率: %.4f%%, PSNR: %.2f dB\n', rate2, success_rate2*100, results.matrix2.psnr);
end
