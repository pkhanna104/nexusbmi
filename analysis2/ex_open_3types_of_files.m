%% Read Arduino data: 
% Rows: 'd1', 'ax', 'ay', 'az', 'axL', 'azL', 'ts', 'hr'
M = dlmread('txt012817c__ard.txt', ',', 1, 0);

t = M(:, 1);
T = t - t(1);

figure();

%Acc R
subplot(3, 2, 1)
plot(T, M(:, [6, 7, 8]));
title('Acc R')

%Acc L
subplot(3, 2, 2)
plot(T, M(:, [3 4]))
title('Acc L')

%Touch
subplot(3, 2, 3)
plot(T, M(:,2))
title('Touch')

%Pulse
subplot(3, 2, 4)
plot(T, M(:, 5))
title('Pulse')

%DT
subplot(3, 2, 5)
plot(T(2:end), diff(T))
title('DT')

%IMUs
subplot(3, 2, 6)
plot(T, M(:, 9:14))
title('Gyro & Mag')

%% Read Neural Data
fname = 'h5_012817c_.h5';
rew = h5read(fname, '/task_events/reward_times');
cursor = h5read(fname, '/task/cursor');
target = h5read(fname, '/task/target');
ideal_pos = h5read(fname, '/task/ideal_pos');
decoded_pos = h5read(fname, '/task/decoded_pos');

neural_ft = h5read(fname, '/neural/features');
packet_seq = h5read(fname, '/neural/packet_seq');
pxx_ch4 = h5read(fname, '/neural/pxx_ch4');
pxx_ch2 = h5read(fname, '/neural/pxx_ch2');
ts_stn = h5read(fname, '/neural/timeseries_stn');
ts_m1 = h5read(fname, '/neural/timeseries_m1');
ts = h5read(fname, '/neural/timestamp');

%Task Figure
figure()
TS = ts -t(1);
ix = 2:length(ts);

plot(TS(ix), cursor(ix))
hold all
plot(TS(ix), target(ix))
plot(TS(ix), ideal_pos(ix))
plot(TS(ix), decoded_pos(ix))
legend('Cursor', 'Target', 'Ideal Pos', 'Decoded Pos')

%Neural Figure;
figure()
plot(TS(ix), pxx_ch2(1,ix), TS(ix), pxx_ch2(2,ix))
hold all
plot(TS(ix), pxx_ch4(1,ix), TS(ix), pxx_ch4(2,ix))
legend('pxx ch2, 1', 'pxx ch2, 2', 'pxx ch4, 1', 'pxx ch4 2')

figure()
subplot(2, 1, 1)
imagesc(ts_stn)
title('TS STN')
subplot(2, 1, 2)
imagesc(ts_m1);
title('TS M1')



