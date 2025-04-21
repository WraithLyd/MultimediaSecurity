function [res] = E_blind(image, pattern, m, alpha)
% image -- 原始图像
% pattern -- 水印模板
% m -- 待嵌入消息位
% alpha -- 水印嵌入强度

res = image;
[width, height] = size(image);
pattern = (m * alpha) * pattern;
for i = 1:width
	for j = 1:height
		res(i,j) = res(i,j) + pattern(i,j);
	end
end
