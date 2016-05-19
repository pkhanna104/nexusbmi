
figure()
subplot(3,1,1)
plot(dat.abs_time, dat.cursor(1:end-1), '-','color',[.8, .8,.8])
hold all
plot(dat.abs_time, dat.target(1:end-1))
plot(dat.abs_time(dat.reward_times{1}), dat.target(dat.reward_times{1}),'r*')

xlim([0, dat.abs_time(end)])
ylim([-8, 8])
legend('Cursor', 'Target Position', 'Score!')

subplot(3,1, 2)
ard_t = length(dat.arduino.t);
plot(dat.arduino.t, dat.arduino.touch_sens )
hold all
plot(dat.arduino.t, (sqrt(sum(dat.arduino.acc(1:ard_t,:).^2, 2))/100)-7)
xlim([0, dat.abs_time(end)])
legend('Touch Sensor 1', 'Touch Sensor 2', 'Norm Acc.')

subplot(3,1,3)
ch4 = rect_cell2mat(dat.rawdata_power_ch4, [2, 1]);
arr_ch4 = cell2mat(ch4);
plot(dat.abs_time, mean(arr_ch4(:, 1:end-1),1))
xlim([0, dat.abs_time(end)])
legend('Beta Power Channel')

