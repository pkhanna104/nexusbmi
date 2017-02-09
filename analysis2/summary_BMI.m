function summary_BMI(dat_str)
% dat_str: e.g. '013117a'
% Read Arduino data: 
% Rows: 'd1', 'ax', 'ay', 'az', 'axL', 'azL', 'ts', 'hr'
try
    M = dlmread(strcat('txt', dat_str, '__ard.txt'), ',', 1, 0);

    t = M(:, 1);
    T = t - t(1);

    figure();

    %Acc R
    subplot(2, 1, 1)
    plot(T, M(:, [6, 7, 8]));
    title('Acc R')
catch
    disp('no arduino')
    t = [0];
end

%Touch
% subplot(4, 1, 2)
% plot(T, M(:,2))
% title('Touch')

%Pulse
% subplot(4, 1, 3)
% plot(T, M(:, 5))
% title('Pulse')

% Read Neural Data
fname = strcat('h5_', dat_str, '_.h5');
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
subplot(2, 1, 2);
TS = ts -t(1);
ix = 2:length(ts);
plot(TS(ix), cursor(ix))
hold all
plot(TS(ix), target(ix))

ix2 = find(target(rew) ~= 0);
for i=1:length(ix2)
    plot([TS(rew(ix2(i)))-6, TS(rew(ix2(i)))], [target(rew(ix2(i))), target(rew(ix2(i)))], 'r*-')
end

subplot(2, 1, 1);
try
    xlim([0, T(end)])
    subplot(2, 1, 2);
    xlim([0, T(end)])
catch
    disp('no ardunion x 2')
end

%plot(TS(ix), ideal_pos(ix))
%plot(TS(ix), decoded_pos(ix))
legend('Cursor', 'Target', 'Tapping')
xlabel('Time (secs)')
ylabel('Y Pos Screen')
subplot(2, 1, 1);
ylabel('Raw Acc Channels - LSB')
end

