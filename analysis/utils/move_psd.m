d = load('dat092815a_.mat');
dat = d.dat;
% Find 4 sec before, 4 sec after movement: 
ix = find(dat.arduino.beep>0);
z = diff(ix);
ix2 = find(z > 1);
ix3 = ix(ix2);

times_ = dat.arduino.t(ix3);

%Init array: 
t_arr = cell(length(times_), 2+4);

%Init pxx array:
% [Pxx,F] = pwelch(X,WINDOW,NOVERLAP,NFFT,Fs) ret
% [S, f] = pwelch(rand(169,1), 128, 0, 128, params.Fs);
[S, f] = pwelch(rand(168, 1), 128, 0, 128, 422);
p_arr = zeros(length(times_), 6, length(f));

for t=1:length(times_)
    [m, ix_t] = min(abs(dat.abs_time - times_(t)));
    
    for j=-2:4
        t_arr{t, j+3} = dat.rawdata_timeseries_m1(ix_t+j,1:168);
        [p_arr(t, j+3, :), f] = pwelch(t_arr{t, j+3}, 128, 0, 128, 422);
    end
    
end

%Figure 1: 
% Mean spectrogram: 
figure(1)
f_lf = f(f<40&f>15);
mn_spec = log10(squeeze(mean(p_arr, 1)));
t = ([1:7]*.4) - 1.2;
imagesc(t, f_lf, mn_spec')

% Beta only spec
figure(2)
beta = f(f>10 & f<20);
beta_ix = find(f>10 & f<30);
spec = squeeze(mean(p_arr(:,:,beta_ix),2));
plot(mean(spec,1))

