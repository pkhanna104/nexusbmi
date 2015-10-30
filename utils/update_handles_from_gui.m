function [handles, keep_running] = update_handles_from_gui(handles);
    
    %Check for stop button:
    keep_running = 1;
    try
        stop = getappdata(handles.figure1, 'stop');
        if stop == 1;
            keep_running=0;
        end
    catch
    end

    %update assist
    try 
        if ~isempty(getappdata(handles.figure1, 'assist_level'))
            handles.decoder.assist_level = getappdata(handles.figure1,'assist_level');
        end
    catch 
    end

    %update lp filter
    try
        if ~isempty(getappdata(handles.figure1, 'lp_filter'))
            handles.decoder.lp_filter = getappdata(handles.figure1,'lp_filter');
        end
    catch
    end
    
        %update hold mean 
    try
        if ~isempty(getappdata(handles.figure1, 'hold_mean'))
            handles.task.hold_time_mean = getappdata(handles.figure1,'hold_mean');
        end
    catch
    end
    
        %update timeout time: 
    try
        if ~isempty(getappdata(handles.figure1, 'timeout'))
            handles.timeoutTime = getappdata(handles.figure1, 'timeout');
        end
    catch
    end
    
        %update hold var
    try
        if ~isempty(getappdata(handles.figure1, 'hold_var'))
            handles.task.hold_time_var = getappdata(handles.figure1,'hold_var');
        end
    catch
    end