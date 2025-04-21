predict = [];
predict_flag = [];
answer = [];
filename = dir('data');
filename = filename(3:end);
filenum = size(filename);
Tlc = 0.6;
pattern = load('task1_data/data1.mat');
pattern = pattern.pattern;

for i = 1:filenum
	for j = -1:1
		image = imread(['data/' filename(i).name]);
		if j ~= 0
			image = E_blind(image, pattern, j, 1);
		end
		k = i*3+j-1;
		answer(k) = j;
		predict(k) = D_LC(image, pattern);
		if predict(k) > Tlc
			predict_flag(k) = 1;
		elseif predict(k) < -Tlc
			predict_flag(k) = -1;
		else
			predict_flag(k) = 0;
		end
	end
end

[accu, false_pos, false_neg] = False_pn(answer, predict_flag);
fprintf('accuracy = %.2f%%\n', accu*100);
fprintf('false positive = %.2f%%\n', false_pos*100);
fprintf('false negative = %.2f%%\n', false_neg*100);

% 绘制分类收集检测值分布图

val1 = []; % m=-1
val2 = []; % m=0
val3 = []; % m=1

for i = 1:filenum*3
	if answer(i) == -1
		val1 = [val1 predict(i)];
	elseif answer(i) == 0
		val2 = [val2 predict(i)];
	elseif answer(i) == 1
		val3 = [val3 predict(i)];
	end
end

x = linspace(-3,3,20);
y1 = hist(val1, x)/length(val1)*100;
y2 = hist(val2, x)/length(val2)*100;
y3 = hist(val3, x)/length(val3)*100;

figure, plot(x,y1,x,y2,x,y3);
hold on;
plot([0.7 0.7], [0 100], 'k--', 'LineWidth', 1);
plot([-0.7 -0.7], [0 100], 'k--', 'LineWidth', 1);
legend('m=-1', 'no watermark', 'm=1', 'Tlc');
axis([-3 3 0 100]);