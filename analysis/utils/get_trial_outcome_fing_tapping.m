function [outcome, final_targ_len, bool_rt] = get_trial_outcome_fing_tapping(targ_next_state,...
    targ_len, dat, targ_pos, tmp, targ_start, ix_add)

% Get trial outcomes for finger tapping task

% Two outcomes: 1) Periph Reward, 2) Central Reward, 3) Timeout Periph
outcome = [];
bool_rt = [];
final_targ_len = [];

for t =1:length(targ_next_state)
    bool_rt_i = -1;
    
    if (targ_pos(t) == 0) && strcmp(targ_next_state{t}, 'tapping')
        code = 15; %Successfully bring to center
        targ_end = tmp(t);
        end_tapping = tmp(t);
        
    elseif(targ_pos(t) == 0) && ~strcmp(targ_next_state{t}, 'tapping')
        code = 14; %Error bring to center
        targ_end = tmp(t);
        end_tapping = tmp(t);
        
    elseif strcmp(targ_next_state{t}, 'tapping')
        
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
            end_tapping = tmp(t)+dt;
            targ_end = tmp(t);
            %bool_rt_i = get_rt(tmp(t), targ_pos(t), dat, tmp(t)+dt);
            
            %Else...if run to end of file?
        else
            code = -1;
            disp(strcat('END OF FILE!'))
        end
        
    % Timeout
    elseif strcmp(targ_next_state{t}, 'wait')
        code = 12;
        targ_end = tmp(t);
        end_tapping = targ_end;
        
    end
    outcome = [outcome ; targ_start(t)+ix_add targ_pos(t) code targ_end+ix_add end_tapping+ix_add];
    final_targ_len = [final_targ_len targ_len(t)];
    bool_rt = [bool_rt 0];
end

end