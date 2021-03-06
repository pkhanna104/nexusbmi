function cleanup_task(handles)
    global nex_inst nex_init;

    % Save data:
    dat = handles.save_data;
    dat.iter_cnt = handles.iter_cnt;
    try
        dat.decoder = handles.decoder;
    catch
        disp('No decoder to Save')
    end
    [filename, handles] = get_data_fname('data',handles);
    save(filename,'dat');
    
    % Add entry to db: 
    only_test = get(handles.testing_box, 'Value');
    [TARG, REW, reach_time, avg, session_length] = db_cleanup(handles, dat, filename, only_test);
    
    if isfield(handles.neural_source_name,'nexus') && (handles.neural_source_name.nexus ==1)
        %nex_inst.setNexusConfiguration(10,2) % reset to defaults
        handles.neural_source.cleanup_neural()
%        handles.neural_source.inst.dispose % clean up properly

    end

    %Save Last Decoder if CLDA was on: 
    if get(handles.clda_box,'value')
        disp('clda');
        it = dat.iter_cnt;
        save_last_clda(it, dat.decoder, handles);
    end
    
    %Turn off BT if used: 
    if get(handles.bt_check_box, 'Value')
        fclose(handles.task.ard.bt);
    end
    
    %Write to exp.txt to stop: 
    [~, paths] = textread('config.txt', '%s %s',5);
    data_dir = paths{3};

    fID = fopen(strcat(data_dir, 'shared_process.txt'), 'w');
    x = 'stop';
    fprintf(fID,'%s', x );
    fclose(fID);
    
    % Make Summary Stats Screen:
    summary_stats(TARG, REW, reach_time, avg, session_length)
    
    %Close GUI
    close(handles.figure1)

    %Close BMI Window
    close(handles.window.task_display)
    
    
    