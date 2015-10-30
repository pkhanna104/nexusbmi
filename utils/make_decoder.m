function make_decoder(handles)

%Get Method: 
ix = get(handles.decoder_method, 'Value');
methods = get(handles.decoder_method, 'String');
method = methods{ix};

%Make decoder;
[FileName,PathName] = uigetfile('*.mat','Select the MATLAB data file');
data = load(strcat(PathName,FileName));
dat = data.dat;

decoder = struct();
%Get correct source for decoder: 
%Array of sources: 
try
    source = dat.decoder.source;
catch
    neural_source = {'sim_nexus_td','sim_nexus_pxx', 'nexus_td','nexus_pxx','accel'};
    [Selection,ok] = listdlg('PromptString','Select Decoder Source Signal',...
        'ListString',neural_source, 'SelectionMode','single');
    source = neural_source{Selection};
end

if strcmp(source(end-1:end), 'td')
    [feats, lower_lim, upper_lim] = extract_freq_feats_from_td(dat);
    
elseif strcmp(source(end-2:end), 'pxx')
    feats  = cell2mat(dat.rawdata_power_ch2);
    lower_lim = 0;
    upper_lim = 0;
    
elseif strcmp(source, 'accel')
    %Data is saved as {[obj.ard_buff.cap], [obj.ard_buff.accel],[0],[0]}
    feats = cell2mat(dat.rawdata_power_ch2);
    feats = sum(feats, 1);
    lower_lim = 0;
    upper_lim = 0;
end
decoder.feature_band = [lower_lim, upper_lim];

if strcmp(method,'simple')
    quarter_step = prctile(feats,50) - prctile(feats,25);
    decoder.mean = prctile(feats, 50);
    decoder.quarter_step = quarter_step;
    decoder.source = source;

    %Map quarter step to target step assuming 4 evenly spaced targets at: [-6,
    %-2, 2, 6], so a distance of four = 1 quarter step
    
    decoder.std = quarter_step/4;
    %decoder.feature_band = handles.feature_extractor.f_ranges(ft_ind(ft_ind==1),:);
    
elseif strcmp(method, 'KF')
    targ_pos = dat.target(1:length(feats));
    decoder = init_KF(feats, decoder, targ_pos);
    decoder.source = source;
end

%Save all trained decoders
decoder.method = method;
save_trained_decoder(handles, lower_lim, upper_lim, decoder)


