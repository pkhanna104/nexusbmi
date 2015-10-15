function handles = run_task(handles, load_dec)
    loop_start = tic;
    data = []; seq = []; feat = [];
    
    if (mod(handles.task.sub_cycle, handles.task.mod_check_neural)==0)
        %Get neural data
        %Data output as 1x2 cell array of vectors or 1x2 cell array of nans
        [data, seq, T] = handles.neural_source.get_neural(handles);
        disp('Data shape: ')
        size(data)
        feat = handles.feature_extractor.extract_features(data);
        handles.save_data.rawdata_abs_time(handles.iter_cnt) = T;
        
        %Calculate Stuff
        if load_dec
            handles = handles.decoder.calc_cursor(feat, handles); 
        end
        handles.iter_cnt = handles.iter_cnt+1;
    end
    
    %Task State Update
    handles = handles.task.cycle(handles);

    %Update Display
    handles = update_display(handles);
    
    %Save Stuff
    handles = save_dat(handles, data, seq, feat, load_dec);

    %How long has it been? Wait? 
    y = toc(loop_start);
    pause(max(0, handles.task.sub_loop_time - y))
    %pause(max(0, handles.task.loop_time-y));
    
    %handles.save_data.loop_time(handles.iter_cnt-1) = toc(loop_start);
    handles.save_data.abs_time(handles.iter_cnt-1) = toc(handles.tic);
    
end