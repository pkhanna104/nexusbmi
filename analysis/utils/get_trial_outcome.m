function [outcome, final_targ_len, bool_rt] = get_trial_outcome(dat, ix_add, ...
    task_name)

targ_start = [];
targ_next_state = [];
targ_len = [];
targ_pos = [];
tmp = [];

cur_state = 'none';
for i = 1:length(dat.state);
    if ~strcmp(dat.state{i}, cur_state)
        
        %If current and prev are different and last was target, then
        %something like a hold error or reward happened
        
        if strcmp(cur_state, 'target')
            targ_next_state = [targ_next_state dat.state{i}];
            targ_len = [targ_len i-targ_start(end)];
            targ_pos = [targ_pos dat.target(i)];
            tmp = [tmp i];
        
        %If current is 'target' then we have a target onset
        elseif strcmp(dat.state{i}, 'target')
            targ_start = [targ_start i];
        
        end
        cur_state = dat.state{i};
    end
end

if strcmp(task_name, 'target_tapping')
    [outcome, final_targ_len, bool_rt] = get_trial_outcome_targ_tapping(targ_next_state,...
        targ_len, dat, targ_pos, tmp, targ_start, ix_add);
elseif strcmp(task_name, 'finger_tapping')
    [outcome, final_targ_len, bool_rt] = get_trial_outcome_fing_tapping(targ_next_state,...
        targ_len, dat, targ_pos, tmp, targ_start, ix_add);    
end
end

function rt = get_rt(idx, targ, data, rew_ix)

if targ == 0
    rt = 0;
else
    %Get beginning of tapping: 
    j = 0;
    while ~strcmp(data.state{idx+j}, 'tapping')
        j = j + 1;
    end
    
    %Find how long is 
    abs_time = data.abs_time(idx+j);
    [~, ard_ix] = min(abs(data.arduino.t - abs_time));
    
    ai = 0;
    
    %Use Start time as time state changes to 'tapping'
    %t0 = data.arduino.t(ard_ix);
    t0 = abs_time;
    
    %Use end time as time touch sensor turns off: 
    while data.arduino.touch_sens(ard_ix+ai,1)
        ai = ai+1;
    end
    rt = data.arduino.t(ard_ix+ai) - t0;
end

end
