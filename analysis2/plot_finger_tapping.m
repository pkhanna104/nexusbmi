function plot_finger_tapping(dat_str)

% dat_str = '010917a'

%Load dat* file:
%load(strcat('dat', dat_str, '_.mat'))

%Plot cursor, target, and reward times: 

fname = strcat('h5_', dat_str, '_.h5');
T = h5read(fname, '/neural/timestamp');
rew = h5read(fname, '/task_events/reward_times');
tap = h5read(fname, '/task_events/start_tapping');
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

% Task Info: 
figure()
subplot(3,1,1)
plot(T, cursor, '-','color',[.8, .8,.8])
hold all
plot(T, target)
plot(T(tap), target(tap),'r*')
plot(T(rew), target(rew),'m*')

xlim([T(2), T(end)]) 
ylim([-8, 8])
legend('Cursor', 'Target Position', 'Tap!', 'Reward!')


% Sensors: 
try
    ard_dat = dlmread(strcat('txt', dat_str, '__ard.txt'), ',', 1, 0);
    T = ard_dat(:, end-1);
    HR = ard_dat(:, end);
    subplot(3,1, 2)
    plot(T, HR)
    hold all
    legend('Touch Sensor 1', 'Touch Sensor 2', 'Norm Acc.')
catch
    disp( ' No Ard Data Found ' )
end

% Neural data: 
subplot(3,1,3)
T2 = resample([zeros(1, 100)+T(2) T(2) T(2:end) T(end)+zeros(1, 100)], 2, 1);
T2 = T2(201:end-200);
ch4 = reshape(pxx_ch4, [size(pxx_ch4, 2)*2, 1]);
ch2 = reshape(pxx_ch2, [size(pxx_ch2, 2)*2, 1]);

plot(T2, ch2, T2, ch4);
xlim([T2(10) T2(end-10)])
legend('Beta Power Channels')

% Neural plus cursor: 
figure;
plot(T, target, 'k--')
hold on
[AX,~,~] = plotyy(T, decoded_pos, T2, ch4);
legend('Target Pos.', 'Decoded Pos.', 'Power Channel')
set(get(AX(1),'Ylabel'),'String','Screen Pos') 
set(get(AX(2),'Ylabel'),'String','Power Channel') 
xlabel('Time, sec.')
