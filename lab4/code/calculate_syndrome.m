function syndrome = calculate_syndrome(coeffs, n, k)
	% 计算syndrome用于矩阵编码
	syndrome = 0;
	for i = 1:length(coeffs)
		if mod(abs(coeffs(i)), 2) == 1
			syndrome = bitxor(syndrome, i-1);
		end
	end
	syndrome = mod(syndrome, 2^k);
end