function handles = save_dat(handles, data, seq, feat, load_dec)

ix = handles.iter_cnt;
if ~isempty(data)
    handles.save_data.state{ix} = handles.task.state;
    handles.save_data.cursor(ix) = handles.window.cursor_pos(2);
    handles.save_data.target(ix) = handles.task.target_y_pos;
    handles.save_data.hold_times{ix} = handles.task.hold;
    
    if load_dec
        handles.save_data.decoded_pos(ix) = handles.decoder.decoded_position(1:end-1);
        handles.save_data.ideal_pos(ix) = handles.decoder.ideal_position;
        handles.save_data.assist_level(ix) = handles.decoder.assist_level;
        handles.save_data.lp_filter(ix) = handles.decoder.lp_filter;
    end
    
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
    
    dm = handles.feature_extractor.domain;
    handles.save_data.features(ix,1:length(feat.(dm))) = feat.(dm);
    handles.save_data.packet_seq(ix,:) = seq;
end

ard_ix = handles.task.sub_cycle;
%handles.save_data.arduino.cap_touch(ard_ix,:) = handles.task.tap_bool; %Relevant touch sensor for task
%handles.save_data.arduino.touch_sens(ard_ix,:) = handles.task.touch_sens; %Two touch sensors
%handles.save_data.arduino.acc(ard_ix,:, :) = handles.task.acc_dat; 
%handles.save_data.arduino.t(ard_ix) = handles.task.sub_cycle_abs_time;

if isprop(handles.neural_source,'ard_buff')
    disp('ye')
    handles.neural_source.ard_buff.cap = [handles.neural_source.ard_buff.cap handles.task.touch_sens'];
    handles.neural_source.ard_buff.accel = [handles.neural_source.ard_buff.accel handles.task.acc_dat'];
end

try
    handles.save_data.arduino.beep(ard_ix) = handles.task.beep_bool;
catch
    dummy=0;
end
end