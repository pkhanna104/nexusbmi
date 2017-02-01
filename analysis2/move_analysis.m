function move_analysis(dat_str)
% dat_str = '010917a'

load(strcat('dat', dat_str, '_.mat'))

%Load M1 timeseries
%time_ser = dat.rawdata_timeseries_m1;
time_ser = dat.rawdata_timeseries_stn;

%Find beep onset

try
    %Old files: 
    ix_beep = find(diff(dat.arduino.beep)>0)+1;
    time_beep = dat.arduino.t(ix_beep);
    disp('Old files\n');
    old_files = 1;
catch
    %New files: 
    ix_beep = find(diff(dat.beep) > 0) + 1;
    time_beep = dat.rawdata_abs_time(ix_beep);
    disp('New files\n');
    old_files = 0;
end

if old_files
    ix_neur = [];
    for t=1:length(time_beep)
        [m, am] = min(abs(dat.abs_time - time_beep(t)));
        ix_neur = [ix_neur am];
    end
else
    ix_neur = ix_beep;
end

%Fs = dat.extractor_params.fs;
Fs = 422;
n_samp = floor(.4*Fs);
nfft=max(2^(nextpow2(n_samp)),n_samp);
iter_cnt = dat.iter_cnt;
    
%Assume that we need M1 cortical data
%[S,f] = mtspectrumc(dat.rawdata_timeseries_m1(1:iter_cnt,1:n_samp-1)', params);
[~,f] = pwelch(randn(1,n_samp-1), n_samp-1,[],nfft,Fs);
S = zeros(iter_cnt, length(f));
for i=1:iter_cnt
    [S(i,:), ~] = pwelch(time_ser(i,1:n_samp-1), n_samp-1, [], nfft, Fs);
end
S = abs(S');

%%%%%%%%%%%%%%%%%%%% FIGURE 1 -- Spectrogram  & Pxx %%%%%%%%%%%%%%%%%%%%%%%
figure();
subplot(2, 1, 1)
imagesc([1:iter_cnt]*.4, f(f<100), log10(S(f<100, :)))
hold on;
for t=1:length(ix_neur)
    plot([ix_neur(t), ix_neur(t)]*.4, [0, 100], 'r-')
end
xlabel('Time, sec.')
ylabel('Freq, Hz.')
title('Pwelch')
xlim([0, iter_cnt*.4])

subplot(2, 1, 2)
ch2 = cell2mat(rect_cell2mat(dat.rawdata_power_ch2, [2, 1]));
ch2 = reshape(ch2, [prod(size(ch2)), 1]);

ch4 = cell2mat(rect_cell2mat(dat.rawdata_power_ch4, [2, 1]));
ch4 = reshape(ch4, [prod(size(ch4)), 1]);

plot(linspace(0, iter_cnt*.4, length(ch2)), ch2, 'b-');
hold all
plot(linspace(0, iter_cnt*.4, length(ch4)), ch4, 'k-');

hold all;
for t=1:length(ix_neur)
    plot([ix_neur(t), ix_neur(t)]*.4, [0, 1024], 'r-')
end

legend('Ch2.', 'Ch4.', 'Sounds')
xlim([0, iter_cnt*.4])

%%%%%%%%%%%%%%%%%%%% FIGURE 2 -- PSDs pre/post_move %%%%%%%%%%%%%%%%%%%%%%%
S_pre = [];
S_post = [];
secs = 2;
pad = ceil(secs/.4);

for t=1:length(ix_neur)
    if ix_neur(t) > pad
        for i=1:pad
            S_pre = [S_pre S(:, ix_neur(t)-i)];
        end
    end
    if ix_neur(t) + pad <= iter_cnt
        for i=1:pad
            S_post = [S_post S(:, ix_neur(t)+i)];
        end
    end
end

figure()
plot(f, log10(mean(S_pre, 2)))
hold all
plot(f, log10(mean(S_post, 2)))
xlabel('Frequency (Hz)')
ylabel('Log10(Pxx)')
legend(strcat('Pre: ', num2str(pad), ' secs'), strcat('Post: ', num2str(pad), ' secs'))


