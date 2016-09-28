function [outcome, final_targ_len, bool_rt] = get_trial_outcome(dat, ix_add)

targ_start = [];
targ_next_state = [];
targ_len = [];
final_targ_len = [];
targ_pos = [];
tapping_start = [];

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

outcome = []; 
bool_rt = [];

for t =1:length(targ_next_state)
    bool_rt_i = -1;
    
    %Timeout > 100 or target acquired (excludes accidental hold error)
    if or(strcmp(targ_next_state{t}, 'hold'), targ_len(t) > 100)
        
        %Possibly a reward: 
        if strcmp(targ_next_state{t}, 'hold');
            
            %Make sure proceeded by a 'reward' before next wait:
            dt = 0;
            
            %Find time of next reward:
            while and(and(~strcmp(dat.state{tmp(t)+dt}, 'reward'),...
                    ~strcmp(dat.state{tmp(t)+dt}, 'wait')),...
                    tmp(t)+dt< length(dat.state))
                dt = dt+1;
            end
            
            

            % If get to wait before reward:
            if strcmp(dat.state{tmp(t)+dt}, 'wait')
                code = -1;
            % If get to reward before wait (most typical)
            elseif strcmp(dat.state{tmp(t)+dt}, 'reward')
                code= 9;
                bool_rt_i = get_rt(tmp(t), targ_pos(t), dat, tmp(t)+dt); 

            %Else...if run to end of file?
            else
                code = -1;
                disp(strcat('WEIRD STATE ORDER!'))
            end

            
        elseif strcmp(targ_next_state{t}, 'wait')
            code = 12;
        end
        outcome = [outcome ; targ_start(t)+ix_add targ_pos(t) code];
        final_targ_len = [final_targ_len targ_len(t)];
        bool_rt = [bool_rt bool_rt_i];
    end
    
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
