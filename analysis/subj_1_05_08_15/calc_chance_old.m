function rew = calc_chance(decoded_curs, simN, timeout, target_sizes)

rew = zeros(simN,1);

for s=1:simN
    state = 'target';
    targ_y_pos = target_gen(1000);
    targ = targ_y_pos(1);
    targ_y_pos = targ_y_pos(2:end);
    
    for c=1:length(decoded_curs)
        target_radius = target_sizes(c);

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
            if d < target_radius
                rew(s) = rew(s)+1;
                state = 'neutral';
                neut_cnt = 0;
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