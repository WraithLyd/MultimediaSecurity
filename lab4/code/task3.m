%% task3.m - F5混洗技术实现
function results = task3(carrier_image, secret_bits)
	fprintf('正在执行F5混洗技术分析...\n');
	
	% 不使用混洗的F5
	fprintf('测试无混洗的F5...\n');
	[stego_no_shuffle, ~] = f5_embed_matrix(carrier_image, secret_bits, [1,3,1]);
	extracted_no_shuffle = f5_extract_matrix(stego_no_shuffle, length(secret_bits), [1,3,1]);
	success_no_shuffle = sum(secret_bits == extracted_no_shuffle) / length(secret_bits);
	
	% 使用混洗的F5
	fprintf('测试带混洗的F5...\n');
	[stego_shuffle, ~] = f5_embed_with_shuffle(carrier_image, secret_bits, [1,3,1]);
	extracted_shuffle = f5_extract_with_shuffle(stego_shuffle, length(secret_bits), [1,3,1]);
	success_shuffle = sum(secret_bits == extracted_shuffle) / length(secret_bits);
	
	% 安全性分析
	security_analysis_no_shuffle = analyze_security(carrier_image, stego_no_shuffle);
	security_analysis_shuffle = analyze_security(carrier_image, stego_shuffle);
	
	results = struct();
	results.no_shuffle = struct('stego', stego_no_shuffle, 'success', success_no_shuffle, 'security', security_analysis_no_shuffle, 'psnr', calculate_psnr(carrier_image, stego_no_shuffle));
	results.with_shuffle = struct('stego', stego_shuffle, 'success', success_shuffle, 'security', security_analysis_shuffle, 'psnr', calculate_psnr(carrier_image, stego_shuffle));
	
	fprintf('无混洗F5 - 成功率: %.4f%%, PSNR: %.2f dB, 安全指标: %.4f\n', success_no_shuffle*100, results.no_shuffle.psnr, security_analysis_no_shuffle);
	fprintf('混洗F5 - 成功率: %.4f%%, PSNR: %.2f dB, 安全指标: %.4f\n', success_shuffle*100, results.with_shuffle.psnr, security_analysis_shuffle);
end