filename = dir('data');
filename = filename(3:end);
filenum = length(filename);

watermask = randi([0,1], [1,8])
alpha = sqrt(8);
seed = 0;
tcc = 0.2;

corr_cnt = 0;
fal_pos_cnt = 0;
fal_neg_cnt = 0;
err_cnt = 0;

for i = 1:filenum
	path = filename(i).name;
	cover = imread(['data/' path]);

	image = E_Trellis(cover, watermask, seed, alpha);
	[masked_predict, noexist_cnt] = D_Trellis(image, seed, tcc);
	% masked_predict
	if masked_predict == watermask
		corr_cnt = corr_cnt + 1;
	elseif noexist_cnt >= 4
		fal_neg_cnt = fal_neg_cnt + 1;
	else
		err_cnt = err_cnt + 1;
	end

	[unmasked_predict, exist_cnt] = D_Trellis(cover, seed, 8);
    %exist_cnt
	if exist_cnt >= 4
		corr_cnt = corr_cnt + 1;
	else
		fal_pos_cnt = fal_pos_cnt + 1;
	end
end

total_cnt = corr_cnt + fal_pos_cnt + fal_neg_cnt + err_cnt;

fprintf('总测试数: %d\n', total_cnt);
fprintf('正确检测率: %.2f%%\n', (corr_cnt/total_cnt) * 100);
fprintf('误检率 (False Positive Rate): %.2f%%\n', (fal_pos_cnt / total_cnt) * 100);
fprintf('漏检率 (False Negative Rate): %.2f%%\n', (fal_neg_cnt / total_cnt) * 100);
fprintf('错误检测率: %.2f%%\n', (err_cnt/total_cnt) * 100);
