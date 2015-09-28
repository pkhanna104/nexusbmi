function handles = init_data_save(handles)

    %Save things
    %Things to save: 
    x = struct;
    x.tot_task_iters = 600;
    
    %Save task info: 
    x.state = cell(x.tot_task_iters,1);
    x.cursor = zeros(x.tot_task_iters,1);
    x.target = zeros(x.tot_task_iters,1);
    
    x.reward_times = {[]};
    x.cursor_size = handles.window.cursor_radius;
    x.target_size = handles.window.target_radius;
    x.task_params = handles.task;
    x.hold_times = {};
    
    %Save neural info:
    x.rawdata_timeseries_m1 = zeros(x.tot_task_iters, 400);
    x.rawdata_timeseries_stn = zeros(x.tot_task_iters, 400);
    x.rawdata_power_ch2 = {};
    x.rawdata_power_ch4 = {};
    x.rawdata_abs_time = zeros(x.tot_task_iters,1);
    
    x.features = zeros(x.tot_task_iters, 100);
    x.packet_seq = zeros(x.tot_task_iters, 2);
    
    x.extractor_params = handles.extractor_params;
    x.decoder = handles.decoding;
    x.assist_level = zeros(x.tot_task_iters, 1);
    x.lp_filter = zeros(x.tot_task_iters, 1);
    x.decoded_pos = zeros(x.tot_task_iters, 1);
    x.ideal_pos = zeros(x.tot_task_iters, 1);
    
    %Save Arduino stuff: 
    x.arduino.cap_touch = zeros(x.tot_task_iters*20, 1);
    x.arduino.acc = zeros(x.tot_task_iters*20, 3);
    x.arduino.abs_time = zeros(x.tot_task_iters*20, 1);
    x.arduino.beep = zeros(x.tot_task_iters*20, 1);
    handles.save_data = x;
