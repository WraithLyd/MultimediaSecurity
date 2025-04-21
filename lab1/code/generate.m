function generate()

mkdir('task1_data');
mkdir('task2_data');
mkdir('task3_data');

pattern = randn(6000, 6000);
save(['task1_data/data1.mat'], 'pattern');

for i = 1:40
	pattern = randn(512, 512);
	save(['task2_data/pattern' num2str(i) '.mat'], 'pattern');
end

for i = 1:40
	pattern = randn(256, 256);
	save(['task3_data/pattern' num2str(i) '.mat'], 'pattern');
end