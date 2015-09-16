function cleanup_task(handles)
    global nex_inst nex_init;

    % Save data:
    dat = handles.save_data;
    dat.iter_cnt = handles.iter_cnt;
    %Adjust for Berkeley / UCSF:
    
    %handles.ucsf: 1 = ucsf, 2 = pk-mbp;
    filename = get_data_fname('data',handles);
    save(filename,'dat');
    
    if isfield(handles.neural_source_name,'nexus') && (handles.neural_source_name.nexus ==1)
        %nex_inst.setNexusConfiguration(10,2) % reset to defaults
        handles.neural_source.cleanup_neural()
%        handles.neural_source.inst.dispose % clean up properly

    end

    %Close GUI
    close(handles.figure1)

    %Close BMI Window
    close(handles.window.task_display)