function handles = calc_cursor(feat, handles)

% feat is a lfp band x 1 array (I think)
task_ind = find(handles.feature_extractor.task_indices_f_ranges>0);
%task_feat = mean(feat.td(task_ind));

%PD: 
task_feat = mean(feat.td.fd);

% Run decoder
% scale task feat:
handles.decoding.decoded_position = (task_feat - handles.decoding.mean)/handles.decoding.std;

% low pass filter: 
if handles.decoding.lp_filter > 1
    earliest_ix = max([1, handles.iter_cnt - handles.decoding.lp_filter + 1]);
    comp_dat = [handles.decoding.decoded_position handles.save_data.cursor(earliest_ix:handles.iter_cnt-1)'];
    handles.decoding.decoded_position = (1/handles.decoding.lp_filter)*sum(comp_dat);
end

% Add assist: 
if ~isempty(handles.task.target_y_pos)
    handles.decoding.ideal_position = handles.task.target_y_pos;
else
    handles.decoding.ideal_position = nan;
end

%If no target, don't weight ideal position 
if isnan(handles.decoding.ideal_position)
    alpha = 0;
else
    alpha = handles.decoding.assist_level/100;
end

ypos = nansum([alpha*handles.decoding.ideal_position; ...
    (1-alpha)*handles.decoding.decoded_position],1);

% Clip cursor to stay on screen: 
if ypos > 10
    ypos=10;
elseif ypos < -10
    ypos = -10;
end

handles.window.cursor_pos(2) = ypos;

