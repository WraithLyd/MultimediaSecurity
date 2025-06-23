function extracted_bits = f5_extract_with_shuffle(stego_image, num_bits, matrix_code)
	% 带混洗的F5提取
	[height, width] = size(stego_image);
	
	% 获取DCT系数（需要与嵌入时相同的顺序）
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
	
	% 应用相同的混洗
	rng(12345);
	shuffle_order = randperm(length(dct_coeffs));
	shuffled_coeffs = dct_coeffs(shuffle_order);
	
	% 矩阵解码
	k = matrix_code(1);
	n = matrix_code(2);
	extracted_bits = [];
	coeff_idx = 1;
	
	while length(extracted_bits) < num_bits && coeff_idx + n - 1 <= length(shuffled_coeffs)
		coeff_group = shuffled_coeffs(coeff_idx:coeff_idx+n-1);
		syndrome = calculate_syndrome(coeff_group, n, k);
		
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
