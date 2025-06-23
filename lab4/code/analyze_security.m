function security_score = analyze_security(original, stego)
	% 简单的安全性分析（基于统计特征）
	orig_dct = dct_analysis(original);
	stego_dct = dct_analysis(stego);
	
	% 计算卡方统计量
	chi_square = sum((orig_dct - stego_dct).^2 ./ (orig_dct + 1));
	security_score = 1 / (1 + chi_square/1000);
end