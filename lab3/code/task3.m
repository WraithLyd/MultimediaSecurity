filename = dir('data');
filename = filename(3:end);
filenum = length(filename);

alpha = sqrt(8);
seed = 0;
tcc = 0.25;

simple_corr_cnt = 0;
simple_fal_pos_cnt = 0;
simple_fal_neg_cnt = 0;
simple_err_cnt = 0;

trellis_corr_cnt = 0;
trellis_fal_pos_cnt = 0;
trellis_fal_neg_cnt = 0;
trellis_err_cnt = 0;

for j = 1:10
	watermask = randi([0,1], [1,8]);
	for i = 1:filenum
		path = filename(i).name;
		cover = imread(['data/' path]);

		image = E_SIMPLE(cover, watermask, seed, alpha);
		[masked_predict, noexist_cnt] = D_SIMPLE(image, seed, 8);

		if masked_predict == watermask
			simple_corr_cnt = simple_corr_cnt + 1;
		elseif noexist_cnt >= 4
			simple_fal_neg_cnt = simple_fal_neg_cnt + 1;
		else
			simple_err_cnt = simple_err_cnt + 1;
		end
	
		[~, exist_cnt] = D_SIMPLE(cover, seed, 8);
	
		if exist_cnt >= 4
			simple_corr_cnt = simple_corr_cnt + 1;
		else
			simple_fal_pos_cnt = simple_fal_pos_cnt + 1;
		end

		image = E_Trellis(cover, watermask, seed, alpha);
		[masked_predict, noexist_cnt] = D_Trellis(image, seed, tcc);
		% masked_predict
		if masked_predict == watermask
			trellis_corr_cnt = trellis_corr_cnt + 1;
		elseif noexist_cnt >= 4
			trellis_fal_neg_cnt = trellis_fal_neg_cnt + 1;
		else
			trellis_err_cnt = trellis_err_cnt + 1;
		end

		[~, exist_cnt] = D_Trellis(cover, seed, 8);

		if exist_cnt >= 4
			trellis_corr_cnt = trellis_corr_cnt + 1;
		else
			trellis_fal_pos_cnt = trellis_fal_pos_cnt + 1;
		end
	end
end

simple_total_cnt = simple_corr_cnt + simple_fal_pos_cnt + simple_fal_neg_cnt + simple_err_cnt;
trellis_total_cnt = trellis_corr_cnt + trellis_fal_pos_cnt + trellis_fal_neg_cnt + trellis_err_cnt;

fprintf('Simple_8 总测试数: %d\n', simple_total_cnt);
fprintf('Simple_8 正确检测率: %.2f%%\n', (simple_corr_cnt/simple_total_cnt) * 100);
fprintf('Simple_8 误检率 (False Positive Rate): %.2f%%\n', (simple_fal_pos_cnt / simple_total_cnt) * 100);
fprintf('Simple_8 漏检率 (False Negative Rate): %.2f%%\n', (simple_fal_neg_cnt / simple_total_cnt) * 100);
fprintf('Simple_8 错误检测率: %.2f%%\n\n\n', (simple_err_cnt/simple_total_cnt) * 100);


fprintf('Trellis 总测试数: %d\n', trellis_total_cnt);
fprintf('Trellis 正确检测率: %.2f%%\n', (trellis_corr_cnt/trellis_total_cnt) * 100);
fprintf('Trellis 误检率 (False Positive Rate): %.2f%%\n', (trellis_fal_pos_cnt / trellis_total_cnt) * 100);
fprintf('Trellis 漏检率 (False Negative Rate): %.2f%%\n', (trellis_fal_neg_cnt / trellis_total_cnt) * 100);
fprintf('Trellis 错误检测率: %.2f%%\n', (trellis_err_cnt/trellis_total_cnt) * 100);
