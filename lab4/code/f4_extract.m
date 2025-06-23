function extracted_bits = f4_extract(stego_image, num_bits)
	% F4提取算法
	[height, width] = size(stego_image);
	extracted_bits = [];
	
	for i = 1:8:height-7
		for j = 1:8:width-7
			if length(extracted_bits) >= num_bits
				extracted_bits = extracted_bits(1:num_bits);
				return;
			end
			
			block = stego_image(i:i+7, j:j+7);
			dct_block = dct2(block);
			
			for u = 1:8
				for v = 1:8
					if (u ~= 1 || v ~= 1) && length(extracted_bits) < num_bits
						coeff = round(dct_block(u,v));
						if coeff ~= 0
							extracted_bits = [extracted_bits, mod(abs(coeff), 2)];
						end
					end
				end
			end
		end
	end
	
	if length(extracted_bits) < num_bits
		extracted_bits = [extracted_bits, zeros(1, num_bits - length(extracted_bits))];
	else
		extracted_bits = extracted_bits(1:num_bits);
	end
end
