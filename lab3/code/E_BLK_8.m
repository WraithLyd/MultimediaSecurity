function image = E_BLK_8(cover, watermark, basic_seed, alpha)
	%	cover		- 待加入水印的图像
	%	watermask   - 水印序列
	%	basic_seed	- 随机种子基数
	%	alpha       - 水印强度

	watermark_matrix = zeros(8, 8); 
	[rows, cols] = size(cover);

	for i = 1:8
		rng(basic_seed+i, 'twister');
		pattern = randn(8, 8);
		
		if watermark(i) == 1
			watermark_matrix = watermark_matrix + pattern;
		else
			watermark_matrix = watermark_matrix - pattern;
		end
	end

	watermark_matrix = watermark_matrix - mean(mean(watermark_matrix));
	watermark_matrix = watermark_matrix/std2(watermark_matrix);

	sum = zeros(8, 8);
	cnt = zeros(8, 8);
	avg = zeros(8, 8);
	for i = 1:rows
		for j = 1:cols
			sum(mod(i-1,8)+1, mod(j-1,8)+1) = sum(mod(i-1,8)+1, mod(j-1,8)+1) + double(cover(i,j));
			cnt(mod(i-1,8)+1, mod(j-1,8)+1) = cnt(mod(i-1,8)+1, mod(j-1,8)+1) + 1;
		end
	end

	for i = 1:8
		for j = 1:8
			avg(i,j) = sum(i,j) / cnt(i,j);
		end
	end
	
	image = im2double(avg) + double(alpha * watermark_matrix);
	delta = double(cnt).*image - double(sum);
	
	image = zeros(rows, cols);
	
	for i = 1:rows
		for j = 1:cols
			pixel = double(image(mod(i-1,8)+1, mod(j-1,8)+1)) + double(delta(mod(i-1,8)+1, mod(j-1,8)+1))/double(cnt(mod(i-1,8)+1, mod(j-1,8)+1));
			if pixel > 255
				pixel = 255;
			elseif pixel < 0
				pixel = 0;
			end
			cnt(mod(i-1,8)+1, mod(j-1,8)+1) = cnt(mod(i-1,8)+1, mod(j-1,8)+1) - 1;
			delta(mod(i-1,8)+1, mod(j-1,8)+1) = delta(mod(i-1,8)+1, mod(j-1,8)+1) - pixel + image(mod(i-1,8)+1, mod(j-1,8)+1);
			image(mod(i-1,8)+1, mod(j-1,8)+1) = pixel;
		end
	end
end