function [stego_image, embedding_rate] = f5_embed_matrix(image, secret_bits, matrix_code)
	% F5算法with矩阵编码
	% matrix_code: [k, n, t] where k bits are embedded using n coefficients
	k = matrix_code(1);
	n = matrix_code(2);
	
	stego_image = image;
	[height, width] = size(image);
	
	% 获取非零DCT系数
	dct_coeffs = [];
	positions = [];
	
	for i = 1:8:height-7
		for j = 1:8:width-7
			block = image(i:i+7, j:j+7);
			dct_block = dct2(block);
			
			for u = 2:8
				for v = 1:8
					if abs(dct_block(u,v)) > 1
						dct_coeffs = [dct_coeffs, round(dct_block(u,v))];
						positions = [positions; i, j, u, v];
					end
				end
			end
		end
	end
	
	% 矩阵编码嵌入
	total_embedded = 0;
	for bit_idx = 1:k:length(secret_bits)
		if bit_idx + k - 1 > length(secret_bits) || total_embedded + n > length(dct_coeffs)
			break;
		end
		
		% 获取k位秘密信息
		secret_group = secret_bits(bit_idx:bit_idx+k-1);
		
		% 获取n个载体系数
		coeff_group = dct_coeffs(total_embedded+1:total_embedded+n);
		
		% 计算syndrome
		syndrome = calculate_syndrome(coeff_group, n, k);
		target = bin2dec(num2str(secret_group));
		
		% 如果syndrome不匹配，修改一个系数
		if syndrome ~= target
			change_idx = mod(bitxor(syndrome, target), n) + 1;
			if change_idx <= length(coeff_group)
				coeff_idx = total_embedded + change_idx;
				pos = positions(coeff_idx, :);
				
				% 修改对应的DCT系数
				i = pos(1); j = pos(2); u = pos(3); v = pos(4);
				block = stego_image(i:i+7, j:j+7);
				dct_block = dct2(block);
				
				if round(dct_block(u,v)) > 0
					dct_block(u,v) = dct_block(u,v) - 1;
				else
					dct_block(u,v) = dct_block(u,v) + 1;
				end
				
				reconstructed_block = idct2(dct_block);
				stego_image(i:i+7, j:j+7) = reconstructed_block;
			end
		end
		
		total_embedded = total_embedded + n;
	end
	
	embedding_rate = k / n;
end