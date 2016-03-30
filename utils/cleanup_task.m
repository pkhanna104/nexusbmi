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
    filename = get_data_fname('data',handles);
    save(filename,'dat');
    
    % Run add entry to db: 
    db_cleanup(handles, dat, filename)
    
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
    %Close GUI
    close(handles.figure1)

    %Close BMI Window
    close(handles.window.task_display)