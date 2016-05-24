function [outcome, final_targ_len] = get_trial_outcome(dat, ix_add)

targ_start = [];
targ_next_state = [];
targ_len = [];
final_targ_len = [];
targ_pos = [];
tapping_start = [];

cur_state = 'none';
for i = 1:length(dat.state);
    if ~strcmp(dat.state{i}, cur_state)
        if strcmp(cur_state, 'target')
            targ_next_state = [targ_next_state dat.state{i}];
            targ_len = [targ_len i-targ_start(end)];
            targ_pos = [targ_pos dat.target(i)];
        elseif strcmp(dat.state{i}, 'target')
            targ_start = [targ_start i];
        end
        cur_state = dat.state{i};
    end
end

outcome = []; 
for t =1:length(targ_next_state)
    if or(strcmp(targ_next_state{t}, 'hold'), targ_len(t) > 100)
        if strcmp(targ_next_state{t}, 'hold');
            code= 9;
        elseif strcmp(targ_next_state{t}, 'wait')
            code = 12;
        end
        outcome = [outcome ; targ_start(t)+ix_add targ_pos(t) code];
        final_targ_len = [final_targ_len targ_len(t)];
    end
end