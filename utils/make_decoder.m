function make_decoder(handles)

%Make decoder;
dat = handles.save_data;
    
%Find modulation
%data: samples x channels
%S: frequency x channels/trials

params = struct('fpass',[0 150],'Fs',dat.extractor_params.fs,'tapers',[3 5]);

Fs = dat.extractor_params.fs;
n_samp = floor(.4*Fs);

[S,f] = mtspectrumc(dat.rawdata_timeseries_stn(1:handles.iter_cnt,1:n_samp-1)', params);

% params = struct('fpass',[0 radio_data.fs/2],'Fs',radio_data.fs,'tapers',[3 5]);
% [S,f] = mtspectrumc(reshape(radio_data.m1(100000+[1:400*100]),[400,100]), params);
% 
figure(99);
subplot(1,2,2);
imagesc(1:size(S,2)*.4,f,log10(squeeze(S)))
xlabel('Time')
ylabel('Frequency')

subplot(2,2,1);
mean_S = log10(mean(S(f<100,:),2));
plot(f(f<100), mean_S);
xlabel('Frequency');
ylabel('Log10 Mean PSD');

subplot(2,2,3);
eps = 10^-20;
demean_s = bsxfun(@minus, log10(S(f<100,:)+eps), mean_S);
std_s = sqrt(var(demean_s,0,2));
plot(f(f<100), std_s);

xlabel('Frequency');
ylabel('Std. Log10 PSD');
hold on;
plot(f(f<100), zeros(length(f(f<100)), 1)+.5, 'r-')

user_fitting = 1;
while user_fitting
    %Ask for threshold: 
    prompt = {'Enter Std. Threshold'};
    dlg_title = 'Threshold Input';
    num_lines = 1;
    def = {'0.5'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    thresh = str2double(answer{1});

    %Find frequencies with variation above threshold: 
    f_above_ind = find(std_s>thresh);
    disp('Frequencies: ');
    freq = [];
    for ff = 1:length(f_above_ind)
        freq = [freq f(f_above_ind(ff))];
    end

    %Display frequencies:
    freq
    
    %Try again?
    answer2 = inputdlg({'Try again? Enter 1 for yes, 0 for no'},'',1,{'1'});
    user_fitting = str2double(answer2{1});
end
    
%Define freq lims: 
prompt = {'Decoder Lower Freq Lim: ', 'Decoder Upper Freq Lim: '};
dlg_title = 'Get Decoder Limits';
num_lines = 1;
def = {'25','40'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

lower_lim = str2double(answer{1});
upper_lim = str2double(answer{2});

%TODO, add this to 'power extractor' so it's not redundant: 
power_inds = find((f >= lower_lim & ...
                  (f <= upper_lim)));

feats = sum(S(power_inds,:),1); 

%ft_ind = handles.feature_extractor.task_indices_f_ranges;
%feats = dat.features(1:handles.iter_cnt-1, ft_ind(ft_ind==1));

[fr, fc] = size(feats);
if fr>1 && fc>1
    fprintf('Too many features: %d', fc)
    return
end

quarter_step = prctile(feats,50) - prctile(feats,25);

decoder = struct();
decoder.mean = prctile(feats, 50);
decoder.quarter_step = quarter_step;

%Map quarter step to target step assuming 4 evenly spaced targets at: [-6,
%-2, 2, 6], so a distance of four = 1 quarter step

decoder.std = quarter_step/4;
decoder.feature_band = [lower_lim, upper_lim];
%decoder.feature_band = handles.feature_extractor.f_ranges(ft_ind(ft_ind==1),:);

if isfield(handles, 'decoder_suffix')
    handles.decoder_suffix = [handles.decoder_suffix '_' answer{1} '-' answer{2}];
else
    handles.decoder_suffix = [answer{1} '-' answer{2}];
end

filename = get_data_fname('decoder',handles);
save(filename, 'decoder')

global nex_inst nex_init;

if isfield(handles.neural_source_name,'nexus') && (handles.neural_source_name.nexus ==1)
    %nex_inst.setNexusConfiguration(10,2) % reset to defaults
    %nex_inst.disconnect
    handles.neural_source.cleanup_neural()
    %handles.neural_source.inst.dispose % clean up properly
end


