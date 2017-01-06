% function to get filename
function [data_filename_ucsf, handles] = get_data_fname(type,handles)
    %Type is 'data' or 'decoder'

    suffx = '';

    if strcmp(type(1:3), 'dec')
        if isfield(handles, 'dec_suffix')
            suffx = handles.dec_suffix;
        end
        try
            data_dir = handles.dec_path;
        catch
             [label paths] = textread('config.txt', '%s %s',5);
            data_dir = paths{3};
        end
    else
        % All data files: ('ard', 'dat', 'h5')
        if isfield(handles, 'dat_suffix')
            suffx = handles.dat_suffix;
        end
        data_dir = handles.dat_path;
    end
    
    
    if isfield(handles, 'curex')
        curex = handles.curex;
    else
        text = 'abcdefghijklmnopqrstuvwxyz';

        % get experiment number
        dlist = dir(data_dir);

        str = ['dat' datestr(date,'mmddyy')];
        str2 = ['h5_' datestr(date,'mmddyy')];
        ex = [];
        for k = 1:length(dlist)
            if length(dlist(k).name)>10
                if strmatch(str,dlist(k).name(1:10))
                    addx = 1;
                elseif strmatch(str2,dlist(k).name(1:10))
                    addx = 1;
                else 
                    addx = 0;
                end

                if addx
                    pattern = dlist(k).name(10);
                    ind = strfind(text,pattern);
                    ex(end+1) = ind;
                end
            end
        end

        if ~isempty(ex)
            curex_ind = max(ex)+1;
            curex = text(curex_ind);
        else
            curex = text(1);
        end
        
        handles.curex = curex;
    end

    if strcmp(type(1:2), 'h5')
        data_filename_ucsf  = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' get(suffx,'String') '.h5'];
    elseif strcmp(type(1:3), 'ard')
        data_filename_ucsf  = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' get(suffx,'String') '_ard.h5'];
    elseif strcmp(type(1:3), 'txt')
        data_filename_ucsf  = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' get(suffx,'String') '_ard.txt'];
    else
        data_filename_ucsf  = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' get(suffx,'String') '.mat'];
    end
        