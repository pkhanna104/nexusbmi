function [outcome, final_targ_len, bool_rt] = get_trial_outcome_targ_tapping(targ_next_state,...
    targ_len, dat, targ_pos, tmp, targ_start, ix_add)

% Get trial outcomes for target tapping task

outcome = []; 
bool_rt = [];
final_targ_len = [];

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