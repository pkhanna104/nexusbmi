function handles = save_dat(handles, data, seq, feat)

ix = handles.iter_cnt;
if ~isempty(data)
    handles.save_data.state{ix} = handles.task.state;
    handles.save_data.cursor(ix) = handles.window.cursor_pos(2);
    handles.save_data.target(ix) = handles.task.target_y_pos;
    handles.save_data.hold_times{ix} = handles.task.hold;
    
    handles.save_data.decoded_pos(ix) = handles.decoding.decoded_position;
    handles.save_data.ideal_pos(ix) = handles.decoding.ideal_position;
    handles.save_data.assist_level(ix) = handles.decoding.assist_level;
    handles.save_data.lp_filter(ix) = handles.decoding.lp_filter;
    
    if strcmp(handles.task.state, 'reward') && ~strcmp(handles.save_data.state{ix-1}, 'reward')
        handles.save_data.reward_times{1} = [handles.save_data.reward_times{1} ix];
        
        %Play a reward sound :)
        z = randperm(length(handles.reward_sounds.file));
        ix = z(1);
        
        y = handles.reward_sounds.file{ix};
        params = handles.reward_sounds.params{ix};
        sound(y, params(1), params(2));
    end
    
    try
        handles.save_data.rawdata_timeseries_m1(ix,1:length(data{3})) = data{3};
        handles.save_data.rawdata_timeseries_stn(ix,1:length(data{1})) = data{1};
        handles.save_data.rawdata_power_ch2{ix} = data{2};
        handles.save_data.rawdata_power_ch4{ix} = data{4};
    catch
    end
    
    
    handles.save_data.features(ix,1:length(feat.fd)) = feat.fd;
    handles.save_data.packet_seq(ix,:) = seq;
end

ard_ix = handles.task.sub_cycle;
handles.save_data.arduino.cap_touch(ard_ix) = handles.task.tap_bool;
handles.save_data.arduino.acc(ard_ix,:) = handles.task.acc_dat; 
handles.save_data.arduino.t(ard_ix) = handles.task.sub_cycle_abs_time;

if isprop(handles.neural_source,'ard_buff')
    handles.neural_source.ard_buff.cap = [handles.neural_source.ard_buff.cap handles.task.tap_bool];
    handles.neural_source.ard_buff.accel = [handles.neural_source.ard_buff.accel handles.task.acc_dat];
end

try
    handles.save_data.arduino.beep(ard_ix) = handles.task.beep_bool;
catch
    dummy=0;
end
end