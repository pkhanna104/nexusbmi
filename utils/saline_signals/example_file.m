% data = load('ex_data.mat');
% m1 = data.d.rawdata_timeseries_stn;
% m1_arr = m1(:, 1:168);
% m1_vect = reshape(m1_arr', [prod(size(m1_arr)), 1]);
% m1_vect = m1_vect/1024;
%Reference m1_vector to actual voltages: 

clear all
% Row 2 -- gamma peak, Row 1 -- ekg
data = load('brpd05_home_visit_5_1_ch0_1_EKG_ch10_11_dysk');
dev_num = 1;
file_fs = data.Fs;
ekg = data.signal(2,:)';

% Center signal: 
ekg_detrend = ekg - mean(ekg);

%Scale to make P2P 0.5 V: 
scale = 0.5 /(max(ekg) - min(ekg));
ekg_sc = ekg_detrend*scale;

play_sig(dev_num, file_fs, ekg_sc)

