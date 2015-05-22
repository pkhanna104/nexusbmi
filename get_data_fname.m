% function to get filename
function [data_filename_ucsf] = get_data_fname(type,handles)
    %Type is 'data' or 'decoder'

    text = 'abcdefghijklmnopqrstuvwxyz';
    
    suffx = '';
    
    if strcmp(type(1:3), 'dat')
        if isfield(handles, 'data_suffix')
            suffx = handles.data_suffix;
        end
    elseif strcmp(type(1:3), 'dec')
        if isfield(handles, 'decoder_suffix')
            suffx = handles.decoder_suffix;
        end
    end
    

    % get experiment number
    if handles.ucsf==1
        data_dir = [handles.root_path type '\'];
    elseif handles.ucsf ==2
        data_dir = [handles.root_path type '/'];
    end
    
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
    
    data_filename_ucsf    = [data_dir type(1:3) datestr(date,'mmddyy') curex '_' suffx '.mat'];