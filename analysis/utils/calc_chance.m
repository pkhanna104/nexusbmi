function [rew, rew_cnt, rew_time, time2targ] = calc_chance(decoded_curs, simN,...
    timeoutTime, targ_sizes)

rew = zeros(simN,1);
rew_cnt = zeros(simN, 4);
rew_time = {};
time2targ = {};
for i = 1:4
    for c = 1:simN
        rew_time{c, i} = [];
        time2targ{c, i} = [];
    end
end
tg = [-6 1; -2 2; 2 3; 6 4];

timeout_cnt = 0;

for s=1:simN
    state = 'target';
    targ_y_pos = target_gen(1000);
    targ = targ_y_pos(1);
    targ_y_pos = targ_y_pos(2:end);
    
    for c=1:length(decoded_curs)
        target_radius = targ_sizes(c);
        if strcmp(state, 'neutral')
            if neut_cnt > 4
                state = 'target';
                targ = targ_y_pos(1);
                targ_y_pos = targ_y_pos(2:end);
            else
                neut_cnt = neut_cnt+1;
            end
        end
        if strcmp(state,'target')
            curs = decoded_curs(c);
            d = abs(curs - targ);
            timeout_cnt = timeout_cnt + 1;
            if d < target_radius
                rew(s) = rew(s)+1;
                ix = find(tg(:,1)==targ);
                rew_cnt(s, tg(ix,2)) = rew_cnt(s, tg(ix,2))+1;
                rew_time{s, tg(ix,2)} = [rew_time{s, tg(ix,2)} c];
                time2targ{s, tg(ix,2)} = [time2targ{s, tg(ix,2)} timeout_cnt];
                state = 'neutral';
                neut_cnt = 0;
                timeout_cnt = 0;
            end
            
            if timeout_cnt*0.4 > timeoutTime
                state = 'neutral';
                neut_cnt = 4;
                timeout_cnt = 0;
            end
        end
    end
end



function targ_y_pos = target_gen(n_targets)
    block = 3;
    
    y = [-6 -2 2 6]';
    Y = repmat(y, [block 1]);

    n_reps = round(n_targets/(4*block));

    targ_y_pos = [];

    for i = 1:n_reps
        idx_shuff = randperm(block*4);
        targ_y_pos = [targ_y_pos; Y(idx_shuff)];
    end
end
end