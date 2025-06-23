function [stego_image, capacity] = f4_embed(image, secret_bits)
	% F4算法：修改DCT系数的LSB
	stego_image = image;
	[height, width] = size(image);
	capacity = 0;
	bit_index = 1;
	
	% 8x8块DCT变换
	for i = 1:8:height-7
		for j = 1:8:width-7
			if bit_index > length(secret_bits)
				return;
			end
			
			block = image(i:i+7, j:j+7);
			dct_block = dct2(block);
			
			% 选择合适的DCT系数进行嵌入（避免DC分量）
			for u = 1:8
				for v = 1:8
					if (u ~= 1 || v ~= 1) && abs(dct_block(u,v)) > 1 && bit_index <= length(secret_bits)
						% F4嵌入规则
						coeff = round(dct_block(u,v));
						if coeff > 0
							if mod(coeff, 2) ~= secret_bits(bit_index)
								if coeff == 1
									dct_block(u,v) = 0;
								else
									dct_block(u,v) = coeff - 1;
								end
							end
							capacity = capacity + 1;
							bit_index = bit_index + 1;
						end
					end
				end
			end
			
			% 反DCT变换
			reconstructed_block = idct2(dct_block);
			stego_image(i:i+7, j:j+7) = reconstructed_block;
		end
	end
end