%% task1.m - F4隐写系统实现
function results = task1(carrier_image, secret_bits)
	fprintf('正在执行F4隐写算法...\n');
	
	% F4嵌入
	[stego_image, capacity] = f4_embed(carrier_image, secret_bits);
	
	% F4提取
	extracted_bits = f4_extract(stego_image, length(secret_bits));
	
	% 计算嵌入成功率
	success_rate = sum(secret_bits == extracted_bits) / length(secret_bits);
	
	% DCT分析
	original_dct = dct_analysis(carrier_image);
	stego_dct = dct_analysis(stego_image);
	
	results = struct();
	results.method = 'F4';
	results.stego_image = stego_image;
	results.extracted_bits = extracted_bits;
	results.success_rate = success_rate;
	results.capacity = capacity;
	results.original_dct = original_dct;
	results.stego_dct = stego_dct;
	results.psnr = calculate_psnr(carrier_image, stego_image);
	
	fprintf('F4算法 - 成功率: %.4f%%, PSNR: %.2f dB\n', success_rate*100, results.psnr);
end