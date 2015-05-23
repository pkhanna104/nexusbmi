% function to get filename
function [data_filename_ucsf] = get_data_fname(type,handles)
    %Type is 'data' or 'decoder'

    text = 'abcdefghijklmnopqrstuvwxyz';
    
    suffx = '';
    
    if strcmp(type(1:3), 'dat')
        if isfield(handles, 'dat_suffix')
            suffx = handles.dat_suffix;
        end
        data_dir = handles.dat_path;
    elseif strcmp(type(1:3), 'dec')
        if isfield(handles, 'dec_suffix')
            suffx = handles.dec_suffix;
        end
        data_dir = handles.dec_path;
    end
    

    % get experiment number
    dlist = dir(data_dir);
    
    str = [type(1:3) datestr(date,'mmddyy')];
    ex = [];
    for k = 1:length(dlist)
        if length(dlist(k).name)>10
            if strmatch(str,dlist(k).name(1:10))
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
    
    data_filename_ucsf    = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' get(suffx,'String') '.mat'];