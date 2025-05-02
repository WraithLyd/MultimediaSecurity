function image = E_SIMPLE(cover, watermark, basic_seed, alpha)
	%	cover		- 待加入水印的图像
	%	watermask   - 水印序列
	%	basic_seed	- 随机种子基数
	%	alpha       - 水印强度

	watermark_matrix = zeros(size(cover)); 
	[rows, cols] = size(cover);
	len = length(watermark);
	total_pixels = rows * cols;

	if len > total_pixels
		error('Watermark len exceeds number of pixels in the cover image.');
	end

	for i = 1:len
		rng(basic_seed+i, 'twister');
		pattern = randn(size(cover));

		for j = 1:rows
			for k = 1:cols
				if watermark(i) == 1
					watermark_matrix(j,k) = watermark_matrix(j,k) + pattern(j,k);
				else
					watermark_matrix(j,k) = watermark_matrix(j,k) - pattern(j,k);
				end
			end
		end
	end

	watermark_matrix = watermark_matrix - mean(mean(watermark_matrix));
	watermark_matrix = watermark_matrix/std2(watermark_matrix);

	image = im2double(cover) + alpha * watermark_matrix;
	for i = 1:rows
		for j = 1:cols
			if image(i,j)>255
				image(i,j)=255;
			elseif image(i,j)<0
				image(i,j)=0;
			end
		end
	end
end