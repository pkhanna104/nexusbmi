function handles = save_dat_HD5(handles, data, seq, feat, load_dec)

fname_h5 = handles.save_data_h5;
ix = handles.iter_cnt;
handles.save_data.target(ix) = handles.task.target_y_pos;

if ~isempty(data)
    handles.save_data.state{ix} = handles.task.state;
    h5write(fname_h5, '/task/cursor', handles.window.cursor_pos(2), [1, ix], [1, 1]);
    h5write(fname_h5, '/task/target',  handles.task.target_y_pos, [1, ix], [1, 1]);
    handles.save_data.state{ix} = handles.task.state;
    handles.save_data.target(ix) = handles.task.target_y_pos;
    handles.save_data.hold_times{ix} = handles.task.hold;
    
    handles.save_data.cursor_size(ix) =  handles.window.cursor_radius;
    handles.save_data.target_size(ix) =  handles.window.target_radius;
    handles.save_data.timeoutTime(ix) =  handles.timeoutTime;
    
    if load_dec
        h5write(fname_h5, '/task/decoded_pos',  handles.decoder.decoded_position(1:end-1), [1, ix], [1, 1]);
        h5write(fname_h5, '/task/ideal_pos',  handles.decoder.ideal_position, [1, ix], [1, 1]);
        handles.save_data.assist_level(ix) = handles.decoder.assist_level;
        handles.save_data.lp_filter(ix) = handles.decoder.lp_filter;
        h5write(fname_h5, '/task/state_ix',handles.task.state_ind, [1, ix], [1, 1]); 
        
    end

    if strcmp(handles.task.state, 'reward') && ~strcmp(handles.save_data.state{ix-1}, 'reward')
        handles.save_data.reward_times{1} = [handles.save_data.reward_times{1} ix];
        handles.rew_cnt = handles.rew_cnt + 1;
        h5write(fname_h5, '/task_events/reward_times', ix, [1, handles.rew_cnt], [1,1]);
        
        %Play a reward sound :)
        z = randperm(length(handles.reward_sounds.file));
        ix = z(1);
        
        y = handles.reward_sounds.file{ix};
        params = handles.reward_sounds.params{ix};
        sound(y, params(1), params(2));
    end
    
    try
        h5write(fname_h5, '/neural/timeseries_m1', data{3}, [1, ix], [length(data{3}), 1]);
        h5write(fname_h5, '/neural/timeseries_stn', data{1}, [1, ix], [length(data{1}), 1]);
        h5write(fname_h5, '/neural/pxx_ch2', data{2}, [1, ix], [2, 1]);
        h5write(fname_h5, '/neural/pxx_ch4', data{4}, [1, ix], [2, 1]);
        dm = handles.feature_extractor.domain;
        h5write(fname_h5, '/neural/features',feat.(dm)',[1, ix], [length(feat.(dm)), 1]);        
        h5write(fname_h5, '/neural/packet_seq',seq', [1, ix], [2, 1]); 
        
        handles.save_data.rawdata_timeseries_m1(ix,1:length(data{3})) = data{3};
        handles.save_data.rawdata_timeseries_stn(ix,1:length(data{1})) = data{1};
        handles.save_data.rawdata_power_ch2{ix} = data{2};
        handles.save_data.rawdata_power_ch4{ix} = data{4};
        
    catch
        disp('skipping neural data')
    end

end
