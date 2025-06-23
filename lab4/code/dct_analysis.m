function dct_hist = dct_analysis(image)
	% DCT系数分析
	[height, width] = size(image);
	all_coeffs = [];
	
	for i = 1:8:height-7
		for j = 1:8:width-7
			block = image(i:i+7, j:j+7);
			dct_block = dct2(block);
			all_coeffs = [all_coeffs, dct_block(:)'];
		end
	end
	
	% dct_hist = hist(all_coeffs, -10:10);
	dct_hist = hist(all_coeffs, -5:5);
end