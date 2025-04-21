function relation = D_LC(image, pattern)
% image -- 待检测图像
% pattern -- 参考水印模板

[width, height] = size(image);
sum = 0.0;
for i = 1:width
    for j = 1:height
        sum = sum + double(image(i,j)) * pattern(i,j);
    end
end
relation = sum / (width*height);