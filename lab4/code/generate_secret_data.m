function secret_data = generate_secret_data()
	% 生成约3KB的测试文本数据
	base_text = 'abcdefghigklmnopqrstuvwxyz';
	% 重复文本直到达到约3KB
	secret_data = '';
	while length(secret_data) < 3000
		% secret_data = [secret_data, base_text, sprintf(' 重复次数:%d ', ceil(length(secret_data)/length(base_text)))];
		secret_data = [secret_data, base_text];
		end
	secret_data = secret_data(1:3000);
end