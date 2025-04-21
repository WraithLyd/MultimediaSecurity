function [accu, false_pos, false_neg] = False_pn(answer, predict)

[width, length] = size(answer);
accu_num = 0;
false_pos_num = 0;
false_neg_num = 0;

for i = 1:length
	if answer(i) == predict(i)
		accu_num = accu_num + 1;
	elseif answer(i) ~= 0 && predict(i) == 0
		false_neg_num = false_neg_num + 1;
	else
		false_pos_num = false_pos_num + 1;
	end
end

accu = double(accu_num)/length;
false_pos = double(false_pos_num)/length;
false_neg = double(false_neg_num)/length;