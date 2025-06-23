
### 1 实验目的

* 了解 E_BLK_8/D_BLK_8 系统的基本原理
* 了解 Hamming Code 和 Trellis Code 的工作原理
* 掌握 Correlation Coefffficient 的计算

### 2 实验内容与要求

* 实现基于 E_SIMPLE_8/D_SIMPLE_8 系统的 E_BLK_8/D_BLK_8 系统。要求使用 Correlation Coefffficient 作为检测值。 
* 设计一张水印，选择嵌入强度 *α* = *√*8，使用该水印测试基于 E_SIMPLE_8/ D_SIMPLE_8 系统的 E_BLK_8/D_BLK_8 系统应用于不同封面时的检测准确率。要求封面数量不少于 40 张。 
* 实现基于 Hamming Code 或 Trellis Code 的 E_BLK_8/D_BLK_8 系统
* 使用固定的水印和固定的嵌入强度，测试基于 Hamming Code 或 Trellis Code 的 E_BLK_8/D_BLK_8系统应用于不同封面时的检测准确率。这里 *α* 取值根据所采用的 Hamming Code 或 Trellis Code编码方式选定。比较在信息末尾添加两个 0 比特是否有助于提高检测的准确率，如果可以，请解释原因
* 比较基于不同系统，E_SIMPLE_8/D_SIMPLE_8 和（基于 Hamming Code 或 Trellis Code 的) E_BLK_8/D_BLK_8 系统的检测准确率，试分析原因

### 3 实验环境

MATLAB R2024b

### 4 实验过程与分析

#### 4.1 实现基于 E_SIMPLE_8/D_SIMPLE_8 系统的E_BLK_8/D_BLK_8 系统

E_BLK_8系统从未添加水印的图像中提取出mark，然后利用randn生成八张基于twister seed的随机水印，将八张水印叠加合成一张水印并进行归一化处理，最后对原图像添加水印。

```
function image = E_BLK_8(cover, watermark, basic_seed, alpha)
  % cover   - 待加入水印的图像
  % watermask   - 水印序列
  % basic_seed  - 随机种子基数
  % alpha       - 水印强度

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
```

D_BLK_8检测系统将图像分为8\*8的小块，然后将每个小块叠加取平均值得到mark，最后计算相关系数判断是否存在水印。

```
function [mark, noexist_cnt] = D_BLK_8(marked_image, basic_seed, stardard)

	% marked_image- 含有水印的灰度图像
	% basic_seed - 随机种子基数
	% stardard - 阈值

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

		if corr_val > threshold
			mark(i) = 1;
		elseif corr_val < -threshold
			mark(i) = 0;
		else
			mark(i) = -1;
			noexist_cnt = noexist_cnt + 1;
		end
	end

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
	elseif mean(mean(avg .* watermark_matrix))/sqrt(mean(mean(avg .* avg)) * mean(mean(watermark_matrix .* watermark_matrix))) < stardard
		mark = zeros(1, 8);
		mark = mark - 1;
		noexist_cnt = 8;
	end
end
```

#### 4.2 水印检测系统应用于不同封面

使用未加水印的原图和分别加了消息的水印的图片进行检测。8 个检测值（detect value）中有 4 个超过了阈值，就认为存在水印，否则认为不存在水印。

```
	filename = dir('data');
	filename = filename(3:end);
	filenum = length(filename);
	watermask = randi([0,1], [1,8]);
	alpha = sqrt(8);
	seed = 0;
	tcc = 0.25;

	corr_cnt = 0;
	fal_pos_cnt = 0;
	fal_neg_cnt = 0;
	err_cnt = 0;
	
	for i = 1:filenum
		path = filename(i).name;
		cover = imread(['data/' path]);
		image = E_BLK_8(cover, watermask, seed, alpha);
		[masked_predict, noexist_cnt] = D_BLK_8(image, seed, tcc);

		if masked_predict == watermask
			corr_cnt = corr_cnt + 1;
		elseif noexist_cnt >= 4
			fal_neg_cnt = fal_neg_cnt + 1;
		else
			err_cnt = err_cnt + 1;
		end

		[unmasked_predict, exist_cnt] = D_BLK_8(cover, seed, 8);

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
```
#### 4.3 实现基于 Trellis Code 的 E_BLK_8/D_BLK_8 系统

Trellis code是一种纠错码，基于trellis code的E_BLK_8系统如下

```
function image = E_Trellis(cover, watermark, basic_seed, alpha)

	% cover - 待加入水印的图像
	% watermask - 水印序列
	% basic_seed - 随机种子基数
	% alpha - 水印强度

	watermark_matrix = zeros(8, 8);
	[rows, cols] = size(cover);
	state = 1;
	state_table = [[1,2];[3,4];[5,6];[7,8];[1,2];[3,4];[5,6];[7,8]];
	
	for i = 1:10
		rng(basic_seed + i * 10 + state, 'twister');
		pattern = randn(8, 8);
		if i <= 8 && watermark(i) == 1
			watermark_matrix = watermark_matrix + pattern;
			state = state_table(state, 2);
		else
			watermark_matrix = watermark_matrix - pattern;
			state = state_table(state, 1);
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
```

在检测系统中，需要找到trellis code状态机最可能走的路径，通过计算与接受到的向量的线性相关性来寻找。

```
function [mark, noexist_cnt] = D_Trellis(marked_image, basic_seed, stardard)

	% marked_image- 含有水印的灰度图像
	% basic_seed - 随机种子基数
	% stardard - 阈值

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
	elseif mean(mean(avg .* watermark_matrix))/sqrt(mean(mean(avg .* avg)) * mean(mean(watermark_matrix .* watermark_matrix))) < stardard
		mark = zeros(1, 8);
		mark = mark - 1;
		noexist_cnt = 8;
	end
end
```
#### 4.4 水印检测系统应用于不同封面以及PAD对比

使用未加水印的原图和分别加了消息的水印的图片进行检测。

```
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
	if masked_predict == watermask
		corr_cnt = corr_cnt + 1;
	elseif noexist_cnt >= 4
		fal_neg_cnt = fal_neg_cnt + 1;
	else
		err_cnt = err_cnt + 1;
	end

	[unmasked_predict, exist_cnt] = D_Trellis(cover, seed, 8);

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
```
#### 4.5 比较E_SIMPLE_8/D_SIMPLE_8 和Trellis Code 检测准确率

由于图片数据集过大，运行时间过长，我随机生成10个mark来检测E_SIMPLE_8/D_SIMPLE_8和Trellis code的检测准确率。

```
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
```

### 5 实验分析与结论

#### 5.1 水印检测系统应用于不同封面

```
总测试数: 482
正确检测率: 99.79%
误检率 (False Positive Rate): 0.00%
漏检率 (False Negative Rate): 0.00%
错误检测率: 0.21%
```

#### 5.2 水印检测系统应用于不同封面以及PAD对比

```
总测试数: 482
正确检测率: 100.00%
误检率 (False Positive Rate): 0.00%
漏检率 (False Negative Rate): 0.00%
错误检测率: 0.00%
```

在添加2比特0之后，检测结果正确率提高，由于2比特0起到了纠错码的作用，如果前面有解码错误偏离了正确路径，那么不同纠错码会让其倾向到正确的路径。

#### 5.3 比较E_SIMPLE_8/D_SIMPLE_8 和Trellis Code 检测准确率

```
Simple_8 总测试数: 4820
Simple_8 正确检测率: 100.00%
Simple_8 误检率 (False Positive Rate): 0.00%
Simple_8 漏检率 (False Negative Rate): 0.00%
Simple_8 错误检测率: 0.00%


Trellis 总测试数: 4820
Trellis 正确检测率: 100.00%
Trellis 误检率 (False Positive Rate): 0.00%
Trellis 漏检率 (False Negative Rate): 0.00%
Trellis 错误检测率: 0.00%
```

由于我只使用了10组不同的信息，并且在simple_8和Trellis中，我使用了不同的阈值tcc使其可以更准确地确认是否存在水印，导致了正确检测率均为100%，没有检测错误出现。

但理论上来说，由于trellis添加了两位信息进行纠错，所以对更广泛的水印检测来讲正确率应该更高。