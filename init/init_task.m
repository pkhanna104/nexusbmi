function [handles] = init_task(handles, load_dec)

%Hack to see if javapath has been added already. If it has, then don't add
%it again. We do this becuase 'javaaddpath' seems to clear local variables,
%and so if to keep track of whether the nexus has already been connected
%to, we don't want to clear the 'nex_init' and 'nex_inst' local variables.

global add_java
if isempty(add_java)
    addpath(genpath(handles.root_path));
    javaaddpath('C:\Nexus\jssc.jar')
    javaaddpath('C:\Nexus\nexus.jar')
    global add_java;
    add_java = 1;
end

%FileSaving:
%1 = ucsf, 2 = pk-mbp

%Function for dealing with not having to keep initializing Nexus
global nex_init;

%If nexus not initialized, set nex_init to zero:
if nex_init~=1
    nex_init = 0;
end

handles.stop = 0;

%Dict of sources / features / etc.
neural_sources = struct();
neural_sources.names = {'sim_nexus_td','sim_nexus_pxx', 'nexus_td','nexus_pxx','accel','sim_accel'};
neural_sources.obj = {@sim_nexus_interface,@sim_nexus_interface, @nexus_interface, @nexus_interface, @accel, @sim_accel};

%Init task
task_sources = struct();
task_sources.names = {'','target_task', 'target_touch_task','movement_task'};
task_sources.obj = {'',@target_task, @target_touch_task, @movement_task};

task_ix = get(handles.task_list_pulldown, 'Value');
if task_ix ==1
    error('Must select a task!')
end
hold_mn = str2num(get(handles.holdMean, 'String'));
hold_var = str2num(get(handles.holdVar, 'String'));
handles.task = task_sources.obj{task_ix}([hold_mn, hold_var]);

%Load reward sounds
handles.reward_sounds = struct;
handles.reward_sounds.file = {};
handles.reward_sounds.params = {};

snds = dir(handles.med_path);
for d = 1:length(snds)
    if length(snds(d).name) > 3
        if strcmp(snds(d).name(end-2:end), 'wav')
            [y, Fs, nbits] = wavread([handles.med_path snds(d).name]);
            handles.reward_sounds.file{end+1} = y;
            handles.reward_sounds.params{end+1} = [Fs, nbits];
        end
    end
end

%Load Mario:
handles.mario.up = imread([handles.med_path 'mario-bros-computer-game.jpg']);

%Create Task Display
handles = init_task_display(handles);

%Init Features Extractor
handles.extractor_params.f_ranges = [0 200; 0 100];
handles.extractor_params.task_f_ranges = [0, 0];

%Update from GUI:
% handles.extractor_params.task_f_ranges(1) = handles.low_frac_lim;
% handles.extractor_params.task_f_ranges(2) = handles.high_frac_lim;
% handles.extractor_params.f_ranges = [handles.extractor_params.f_ranges; ...
%     handles.extractor_params.task_f_ranges];

%Create Task_Data Saving
handles.iter_cnt = 1;
handles = init_data_save(handles, load_dec);

%Init Decoder:
if load_dec
    DL = get(handles.decoder_list,'String');
    ix = get(handles.decoder_list,'Value');
    
    dec  = load(DL{ix});
    %For compatibility with old decoders
    if ~isfield(dec.decoder,'method')
        dec.decoder.method = 'simple';
    end
    if strcmp(dec.decoder.method, 'simple')
        handles.decoder = decoder_simple(DL{ix},handles);
    elseif strcmp(dec.decoder.method, 'KF')
        handles.decoder = decoder_KF(DL{ix},handles);
    end
    
    %Add spectral feature to decoder if necessary
    handles.extractor_params.f_ranges = [handles.extractor_params.f_ranges; ...
        handles.decoder.feature_band];
    handles.extractor_params.task_f_ranges = handles.decoder.feature_band;
    
else
    % In case of calibration:
    handles.decoding.mean = 0;
    handles.decoding.std = 1;
    handles.decoding.assist_level = 0;
    handles.decoding.lp_filter = 1;
end


%Init Extractor: 
extractor_sources = struct();
extractor_sources.names = {'Nexus Power Ext.', 'Accel Ext.'};
extractor_sources.obj = {@nexus_power_extractor, @accel_extractor};

if isfield(handles, 'extractor_name')
    ext_str = handles.extractor_name;
    for e=1:length(extractor_sources.names)
        if strcmp(extractor_sources.names{e}, ext_str)
            handles.feature_extractor = extractor_sources.obj{e}(handles.extractor_params);
        end
    end
else
     handles.feature_extractor = nexus_power_extractor(handles.extractor_params);
end

%Init Neural Interface
%Check that a neural source is selected:
if isfield(handles, 'neural_source_name')
    source = handles.neural_source_name;
    if isfield(handles,'neural_source')
                
        prompt = 'Already a neural source instantiated! Override? 0 or 1';
        override = input(prompt);
    else
        override = 1;
    end
            
    if override
        %Find index for name of neural source:
        idx = find(ismember(neural_sources.names, source));

        if isempty(idx)
            disp('Error: neural source not listed in line 9, init task.m')
        else
            %Instantiate neural source object
            handles.neural_source = neural_sources.obj{idx}(handles);
            handles.neural_source.start_stream;
        end
    end
        
else
    disp('Error: No neural source selected')
end

%Initialize arduino
if and(isprop(handles.task,'ard'), get(handles.ard_check,'Value'))
    if isnan(handles.task.ard)
        if get(handles.bt_check_box, 'Value')
            handles.task.ard = bt_ard();
        else
            com_port = get(handles.arduino_comport, 'String');
            delete(instrfind({'Port'},{com_port}))
            handles.task.ard = arduino(com_port);
            pinMode(handles.task.ard, 8, 'input')
        end
    end
end

end


