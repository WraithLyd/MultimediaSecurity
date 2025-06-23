function bits = text_to_bits(text)
	% 将文本转换为二进制位串
	ascii_vals = double(text);
	bits = [];
	for i = 1:length(ascii_vals)
		byte_bits = dec2bin(ascii_vals(i), 8) - '0';
		bits = [bits, byte_bits];
	end
end