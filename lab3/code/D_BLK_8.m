function [mark, noexist_cnt] = D_BLK_8(marked_image, basic_seed, stardard)
	%		marked_image- 含有水印的灰度图像
	%		basic_seed	- 随机种子基数
	%		stardard		-	阈值

	threshold = 0.0001;
	noexist_cnt = 0;
	[rows, cols] = size(marked_image);
	sum = zeros(8, 8);
	cnt = zeros(8, 8);
	avg = zeros(8, 8);

	for i = 1:rows
		for j = 1:cols
			sum(mod(i-1,8)+1, mod(j-1,8)+1) = sum(mod(i-1,8)+1, mod(j-1,8)+1) + double(marked_image(i,j));
			cnt(mod(i-1,8)+1, mod(j-1,8)+1) = cnt(mod(i-1,8)+1, mod(j-1,8)+1) + 1;
		end
	end

	for i = 1:8
		for j = 1:8
			avg(i,j) = sum(i,j) / cnt(i,j);
		end
	end

	mark = zeros(1, 8);

	for i = 1:8
		rng(basic_seed+i, 'twister');
		pattern = randn(8,8);
		
		corr_val = mean(mean(im2double(avg) .* pattern));
		% corr_val
		if corr_val > threshold
			mark(i) = 1;
		elseif corr_val < -threshold
			mark(i) = 0;
		else
			mark(i) = -1;
			noexist_cnt = noexist_cnt + 1;
		end
  end
	% mark

	watermark_matrix = zeros(8, 8);

	for i = 1:8
		rng(basic_seed+i, 'twister');
		pattern = randn(8, 8);
		
		if mark(i) == 1
			watermark_matrix = watermark_matrix + pattern;
		else
			watermark_matrix = watermark_matrix - pattern;
		end
	end

	watermark_matrix = watermark_matrix - mean(watermark_matrix);
	avg = avg - mean(avg);

	if (mean(mean(avg .* avg)) * mean(mean(watermark_matrix .* watermark_matrix))) < 0.0000000000001
		mark = zeros(1, 8);
		mark = mark - 1;
		noexist_cnt = 8;
		% 1
	elseif mean(mean(avg .* watermark_matrix))/sqrt(mean(mean(avg .* avg)) * mean(mean(watermark_matrix .* watermark_matrix))) < stardard
		mark = zeros(1, 8);
		mark = mark - 1;
		noexist_cnt = 8;
		% mean(mean(avg .* watermark_matrix))/sqrt(mean(mean(avg .* avg)) * mean(mean(watermark_matrix .* watermark_matrix)))
	end
end