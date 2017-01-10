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
% try
%     source = dat.decoder.source;
% catch
    neural_source = {'sim_nexus_td','sim_nexus_pxx', 'nexus_ch1_td',...
        'nexus_ch3_td', 'nexus_ch2_pxx','nexus_ch4_pxx','accel'};
    
    [Selection,ok] = listdlg('PromptString','Select Decoder Source Signal',...
        'ListString',neural_source, 'SelectionMode','single');
    source = neural_source{Selection};
%end

disp(strcat('Using source: ', source))

if strcmp(source(end-1:end), 'td')
    if ~isempty(strfind(source, '3'))
        channel = 3;
    elseif ~isempty(strfind(source, '1'))
        channel = 1;
    elseif ~isempty(strfind(source, 'sim'))
        channel = 1;
    else
        disp('Error! Not a sim channel nor a designated channel')
    end
   
    [feats, lower_lim, upper_lim] = extract_freq_feats_from_td(dat, channel);
    
elseif strcmp(source(end-2:end), 'pxx')
    if ~isempty(strfind(source, '2'))
        channel = 'rawdata_power_ch2';
    elseif ~isempty(strfind(source, '4'))
        channel = 'rawdata_power_ch4';
    elseif ~isempty(strfind(source, 'sim'))
        channel = 'rawdata_power_ch4';
    else
        disp('Error! Not a sim pxx channel nor a designated channel');
    end
    
    rect_pwr = {};
    for ii = 1:length(dat.(channel))
        if size(dat.(channel){ii},1) ~=2
            rect_pwr{ii} = [];
            disp(strcat('Empty ix: ', num2str(ii)));            
        else
            rect_pwr{ii} = dat.(channel){ii};
        end
    end
    feats  = cell2mat(rect_pwr);
    feats = mean(feats, 1);
    lower_lim = 0;
    upper_lim = 0;
    
elseif strcmp(source, 'accel')
    %Deprecated
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
    sel = -1;
    while sel<0
        sel = input('Use Target Info? 1 for Yes, 0 for No (do not use for movement task decoders): ');
    end
    
    if sel
        targ_pos = dat.target(1:length(feats));
        disp('Using targ info')
    else
        targ_pos = [];
    end
    
    decoder = init_KF(feats, decoder, targ_pos);
    decoder.source = source;

elseif strcmp(method, 'perc_pdf')
   decoder = init_perc_pdf_dec(feats, decoder); 
   decoder.source = source;
    
end

%Save all trained decoders
decoder.method = method;
save_trained_decoder(handles, lower_lim, upper_lim, decoder)


