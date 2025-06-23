function [mark, noexist_cnt] = D_Trellis(marked_image, basic_seed, stardard)
	%		marked_image- 含有水印的灰度图像
	%		basic_seed	- 随机种子基数
	%		stardard		-	阈值

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

	old_mark = zeros(8, 8);
	new_mark = zeros(8, 8);
	% old_mark = old_mark - 1;
	% new_mark = new_mark - 1;
	old_lc = [0, -1, -1, -1, -1, -1, -1, -1];
	new_lc = zeros(1, 8);	
	state_table = [[1,2];[3,4];[5,6];[7,8];[1,2];[3,4];[5,6];[7,8]];

	for i = 1:8
		new_lc = new_lc - 1;
		for state = 1:8
			if old_lc(state) ~= -1
				rng(basic_seed + i * 10 + state, 'twister');
				pattern = randn(8 ,8);
				temp = mean(mean(avg .* pattern));
				new_state = state_table(state, 1);
				if new_lc(new_state) == -1
					new_lc(new_state) = old_lc(state) - temp;
					new_mark(new_state, :) = old_mark(state, :);
				elseif new_lc(new_state) < old_lc(state) - temp
					new_lc(new_state) = old_lc(state) - temp;
					new_mark(new_state, :) = old_mark(state, :);
				end
				new_state = state_table(state, 2);
				if new_lc(new_state) == -1
					new_lc(new_state) = old_lc(state) + temp;
					new_mark(new_state, :) = old_mark(state, :);
					new_mark(new_state, i) = 1;
				elseif new_lc(new_state) < old_lc(state) + temp
					new_lc(new_state) = old_lc(state) + temp;
					new_mark(new_state, :) = old_mark(state, :);
					new_mark(new_state, i) = 1;
				end
			end
		end
		old_lc = new_lc;
		old_mark = new_mark;
	end

	for i = 9:10 
		new_lc = new_lc - 1;
		for state = 1:8
			if old_lc(state) ~= -1
				rng(basic_seed + i * 10 + state, 'twister');
				pattern = randn(8 ,8);
				temp = mean(mean(avg .* pattern));
				new_state = state_table(state, 1);
				if new_lc(new_state) == -1
					new_lc(new_state) = old_lc(state) - temp;
					new_mark(new_state, :) = old_mark(state, :);
				elseif new_lc(new_state) < old_lc(state) - temp
					new_lc(new_state) = old_lc(state) - temp;
					new_mark(new_state, :) = old_mark(state, :);
				end
			end
		end
		old_lc = new_lc;
		old_mark = new_mark;
	end

	final_state = 1;
	for state = 1:8
		if old_lc(state) > old_lc(final_state)
			final_state = state;
		end
	end

	mark = old_mark(final_state, :);
	watermark_matrix = zeros(8, 8);

	state = 1;
	for i = 1:10
		rng(basic_seed + i * 10 + state, 'twister');
		pattern = randn(8, 8);
		
		if i <= 8 && mark(i) == 1
			watermark_matrix = watermark_matrix + pattern;
			state = state_table(state, 2);
		else
			watermark_matrix = watermark_matrix - pattern;
			state = state_table(state, 1);
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

	% for i = 1:8
	% 	if mark(i) == -1
	% 		noexist_cnt = noexist_cnt + 1;
	% 	end
	% end
end