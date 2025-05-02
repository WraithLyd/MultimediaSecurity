filename = dir('data');
filename = filename(3:end);
filenum = length(filename);

watermask = randi([0,1], [1,8]);
alpha = sqrt(8);
seed = 0;
len = 8;
corr_list = [];
fal_pos_list = [];
fal_neg_list = [];
err_list = [];
mask_len = [];

for i = 1:20
	mask_len = [mask_len,len];
	watermask = randi([0,1], [1,len]);
	corr_cnt = 0;
	fal_pos_cnt = 0;
	fal_neg_cnt = 0;
	err_cnt = 0;
	for j = 1:filenum
		path = filename(i).name;
		cover = imread(['data/' path]);
	
		image = E_SIMPLE(cover, watermask, seed, alpha);
		[masked_predict, noexist_cnt] = D_SIMPLE(image, seed, len);
		
		if masked_predict == watermask
			corr_cnt = corr_cnt + 1;
		elseif noexist_cnt >= 4
			fal_neg_cnt = fal_neg_cnt + 1;
		else
			err_cnt = err_cnt + 1;
		end
	
		[unmasked_predict, exist_cnt] = D_SIMPLE(cover, seed, 8);
	
		if exist_cnt >= 4
			corr_cnt = corr_cnt + 1;
		else
			fal_pos_cnt = fal_pos_cnt + 1;
		end
	end
	total_cnt = corr_cnt + fal_pos_cnt + fal_neg_cnt + err_cnt;
	corr_list = [corr_list, corr_cnt/total_cnt*100];
	fal_pos_list = [fal_pos_list, fal_pos_cnt/total_cnt*100];
	fal_neg_list = [fal_neg_list, fal_neg_cnt/total_cnt*100];
	err_list = [err_list, err_cnt/total_cnt*100];
	len = len + 16;
end

plot(mask_len, corr_list, 'r', mask_len, fal_pos_list, 'b', mask_len, fal_neg_list, 'g', mask_len, err_list, 'm');
legend('accu', 'false\_pos', 'false\_neg', 'error');

xlabel('信息位数');
ylabel('检测率');
title( '信息长度增加对检测准确率的影响');
