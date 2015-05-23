function handles = run_task(handles)
    loop_start = tic; 
    
    %Get neural data
    %Data output as 1x2 cell array of vectors or 1x2 cell array of nans
    [data, seq] = handles.neural_source.get_neural(handles);
    disp('Data shape: ')
    size(data)
    feat = handles.feature_extractor.extract_features(data);

    %Calculate Stuff
    handles = calc_cursor(feat, handles); 
    
    %Task State Update
    handles = handles.task.cycle(handles);

    %Update Display
    handles = update_display(handles);
    
    %Save Stuff
    handles = save_dat(handles, data, seq, feat);

    %How long has it been? Wait? 
    y = toc(loop_start);
    pause(max(0, handles.task.loop_time-y));
    handles.iter_cnt = handles.iter_cnt+1;
    handles.save_data.loop_time(handles.iter_cnt-1) = toc(loop_start);
    handles.save_data.abs_time(handles.iter_cnt-1) = toc(handles.tic);
    
end