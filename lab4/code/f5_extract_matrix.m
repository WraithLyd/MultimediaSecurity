function extracted_bits = f5_extract_matrix(stego_image, num_bits, matrix_code)
	% F5提取算法with矩阵编码
	k = matrix_code(1);
	n = matrix_code(2);
	
	[height, width] = size(stego_image);
	
	% 获取DCT系数
	dct_coeffs = [];
	
	for i = 1:8:height-7
		for j = 1:8:width-7
			block = stego_image(i:i+7, j:j+7);
			dct_block = dct2(block);
			
			for u = 2:8
				for v = 1:8
					if abs(dct_block(u,v)) > 0.5
						dct_coeffs = [dct_coeffs, round(dct_block(u,v))];
					end
				end
			end
		end
	end
	
	% 矩阵解码
	extracted_bits = [];
	coeff_idx = 1;
	
	while length(extracted_bits) < num_bits && coeff_idx + n - 1 <= length(dct_coeffs)
		coeff_group = dct_coeffs(coeff_idx:coeff_idx+n-1);
		syndrome = calculate_syndrome(coeff_group, n, k);
		
		% 将syndrome转换为k位二进制
		bit_group = dec2bin(syndrome, k) - '0';
		extracted_bits = [extracted_bits, bit_group];
		
		coeff_idx = coeff_idx + n;
	end
	
	if length(extracted_bits) > num_bits
		extracted_bits = extracted_bits(1:num_bits);
	elseif length(extracted_bits) < num_bits
		extracted_bits = [extracted_bits, zeros(1, num_bits - length(extracted_bits))];
	end
end