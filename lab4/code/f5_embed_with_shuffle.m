function [stego_image, embedding_rate] = f5_embed_with_shuffle(image, secret_bits, matrix_code)
	% 带混洗的F5嵌入
	[height, width] = size(image);
	
	% 获取所有DCT系数和位置
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
	
	% 混洗DCT系数顺序
	rng(12345);
	shuffle_order = randperm(length(dct_coeffs));
	shuffled_coeffs = dct_coeffs(shuffle_order);
	shuffled_positions = positions(shuffle_order, :);
	
	% 使用混洗后的系数进行F5嵌入
	stego_image = image;
	k = matrix_code(1);
	n = matrix_code(2);
	
	total_embedded = 0;
	for bit_idx = 1:k:length(secret_bits)
		if bit_idx + k - 1 > length(secret_bits) || total_embedded + n > length(shuffled_coeffs)
			break;
		end
		
		secret_group = secret_bits(bit_idx:bit_idx+k-1);
		coeff_group = shuffled_coeffs(total_embedded+1:total_embedded+n);
		
		syndrome = calculate_syndrome(coeff_group, n, k);
		target = bin2dec(num2str(secret_group));
		
		if syndrome ~= target
			change_idx = mod(bitxor(syndrome, target), n) + 1;
			if change_idx <= length(coeff_group)
				coeff_idx = total_embedded + change_idx;
				pos = shuffled_positions(coeff_idx, :);
				
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
