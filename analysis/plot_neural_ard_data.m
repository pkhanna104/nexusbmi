%% Load Data file: 

%% Plot M1 data;
t = dat.abs_time; 
neur_t = zeros(168, length(t));
neur_t(1,:) = t;
for i = 1:length(t)
    neur_t(2:end,i) = neur_t(1,i) +[1:167]/422;
end
m1 = dat.rawdata_timeseries_m1(1:length(t), 1:168);

T = reshape(neur_t, [prod(size(neur_t)), 1]);
M1 = reshape(m1', [prod(size(m1)), 1]);
plot(T, M1, '-')

%% Plot Power Data: 
pxx = zeros(length(t),1);
pxx2 = zeros(length(t),1);

for i=1:length(pxx)
    try
        pxx(i) = dat.rawdata_power_ch2{i}(1);
        pxx2(i) = dat.rawdata_power_ch2{i}(2);
    catch
        disp(strcat('empty: ', num2str(i)))
    end
end
hold all
plot(t, pxx)
plot(t, pxx2)

%% Plot Arduino Data
ard_t = dat.arduino.abs_time;
ard_t = dat.arduino.t;
acc = dat.arduino.acc(1:length(ard_t),:);
cap = dat.arduino.cap_touch(1:length(ard_t));
hold all
plot(ard_t, acc)
plot(ard_t, (cap*10)+500)