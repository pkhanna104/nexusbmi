function handles = init_data_save_HD5(handles, load_dec)

    %Return a string with .mat ending
    [fname_h5, handles] = get_data_fname('h5_data',handles);
    
    %Create H5 file: 
    %NEEDED: PLACE TO LIST handles.task.FSM, task_params (handles.task),
    %extractor params
    
    h5create(fname_h5, '/task/cursor',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task/target',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task/state_ix',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task/decoded_pos',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task/ideal_pos',[1, Inf], 'ChunkSize', [1, 10]);
    
    h5create(fname_h5, '/task_events/reward_times',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task_events/start_tapping', [1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/task_events/hold_times',[1, Inf], 'ChunkSize', [1, 10]);
    
    %h5create(fname_h5, '/task_params/cursor_rad',[1, Inf], 'ChunkSize', [1, 10]);
    %h5create(fname_h5, '/task_params/target_rad',[1, Inf], 'ChunkSize', [1, 10]);
    %h5create(fname_h5, '/task_params/assist_level',[1, Inf], 'ChunkSize', [1, 10]);
    %h5create(fname_h5, '/task_params/lp_filter',[1, Inf], 'ChunkSize', [1, 10]);
    %h5create(fname_h5, '/task_params/nf_timeout_time', [1, Inf], 'ChunkSize', [1, 10]); 

    h5create(fname_h5, '/neural/timeseries_m1',[400, Inf], 'ChunkSize', [400, 10]);    
    h5create(fname_h5, '/neural/timeseries_stn',[400, Inf], 'ChunkSize', [400, 10]);    
    h5create(fname_h5, '/neural/pxx_ch2',[2, Inf], 'ChunkSize', [2, 10]);    
    h5create(fname_h5, '/neural/pxx_ch4',[2, Inf], 'ChunkSize', [2, 10]); 
    h5create(fname_h5, '/neural/packet_seq',[2, Inf], 'ChunkSize', [2, 10]); 
    h5create(fname_h5, '/neural/timestamp',[1, Inf], 'ChunkSize', [1, 10]);
    h5create(fname_h5, '/neural/features',[50, Inf], 'ChunkSize', [50, 10]);
    
    %Save things
    %Things to save: 
    %Save task info: 
    x = struct;
    x.task_name = handles.task_name;
    x.task = handles.task;
    x.tot_task_iters = 30*60*2.5;
    x.state = cell(x.tot_task_iters,1);
    x.target = zeros(x.tot_task_iters, 1);
    x.beep = zeros(x.tot_task_iters, 1);
    x.reward_times = {[]};
    x.hold_times = {};
    x.assist_level = zeros(x.tot_task_iters, 1);
    x.lp_filter = zeros(x.tot_task_iters, 1);
    x.cursor_size = zeros(x.tot_task_iters, 1);
    x.target_size = handles.window.target_radius;
    x.timeoutTime = zeros(x.tot_task_iters, 1);
    x.extractor_params = handles.extractor_params;
    x.rawdata_timeseries_m1 = zeros(x.tot_task_iters, 400);
    x.rawdata_timeseries_stn = zeros(x.tot_task_iters, 400);
    x.rawdata_power_ch2 = {};
    x.rawdata_power_ch4 = {};
    
    
    DL = get(handles.decoder_list,'String');
    ix = get(handles.decoder_list,'Value');
    dec  = DL{ix};
    x.decoder_name = dec;

    handles.save_data = x;
    handles.save_data_h5 = fname_h5;
    handles.rew_cnt = 0;
    
    
    fprintf('save_data_h5 added to handles\n')
    
    

