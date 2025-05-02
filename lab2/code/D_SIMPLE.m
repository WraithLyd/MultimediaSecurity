function [mark, noexist_cnt] = D_SIMPLE(marked_image, basic_seed, len)
	%		marked_image- 含有水印的灰度图像
	%		basic_seed	- 随机种子基数
	%   len					- 水印的长度

	threshold = 0.01;
	noexist_cnt = 0;
	image_double = im2double(marked_image);
	mark = zeros(1, len);
	[rows, cols] = size(marked_image);

	for i = 1:len
		rng(basic_seed+i, 'twister');
		pattern = randn(size(marked_image));
		
		corr_val = mean(mean(image_double .* pattern(1:rows,1:cols)));
		if corr_val > threshold
			mark(i) = 1;
		elseif corr_val < -threshold
			mark(i) = 0;
		else
			mark(i) = -1;
			noexist_cnt = noexist_cnt + 1;
		end
	end
end