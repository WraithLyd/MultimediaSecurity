function psnr_value = calculate_psnr(original, stego)
	% 计算PSNR
	mse = mean((original(:) - stego(:)).^2);
	if mse == 0
		psnr_value = inf;
	else
		psnr_value = 10 * log10(255^2 / mse);
	end
end
