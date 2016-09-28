function [rew, rew_cnt, rew_time, time2targ, rew_sim_act] = calc_chance(decoded_curs,...
    targ_locs, rew_ix, asst, simN, timeoutTime, targ_sizes, task_name, tapping_ix)

if strcmp(task_name, 'target_tapping')
    tapping_ix = tapping_ix';
    tapping_time = mean(tapping_ix(1,tapping_ix(1,:)>1));
    reset_time = mean(tapping_ix(2,tapping_ix(2,:)));
    pause_time = round(tapping_time+reset_time);
    targ_exc = [0];
    exc_pause_time =4;
    
elseif strcmp(task_name, 'target_task')
    ix_null = find(targ_locs==0);
    decoded_curs(ix_null) = -10000;
    tapping_time = 0;
    reset_time = 4;
    pause_time = round(tapping_time+reset_time);
    targ_exc = [];
end

targ_locs_gen = [targ_locs(rew_ix)];
rew = zeros(simN,1);
rew_cnt = zeros(simN, 4);
rew_time = {};
time2targ = {};
for ii = 1:4
    for c = 1:simN
        rew_time{c, ii} = [];
        time2targ{c, ii} = [];
    end
end


timeout_cnt = 0;

for s=1:simN
    state = 'target';
    if strcmp(task_name, 'target_tapping')
        targ_y_pos = three_targ_co_gen(1000);
        tg = [-6 1; 0 2; 6 3];
        
    elseif strcmp(task_name, 'target_task')
        targ_y_pos = target_gen(1000);
        tg = [-6 1; -2 2; 2 3; 6 4];
    end
    
    if s == simN
        if strcmp(task_name, 'target_tapping')
            targ_y_pos = [targ_locs_gen; three_targ_co_gen(1000)];
        elseif strcmp(task_name, 'target_task')
            targ_y_pos = [targ_locs_gen; target_gen(1000)];
        end
        
        size(targ_y_pos)
    end
    targ = targ_y_pos(1);
    
    if sum(targ==targ_exc) >0
        trial_pause_time = exc_pause_time;
    else
        trial_pause_time = pause_time;
    end
    
    targ_y_pos = targ_y_pos(2:end);
    
    for c=1:length(decoded_curs(2:end))
        target_radius = targ_sizes(c);
        
        if strcmp(state, 'neutral')
            if neut_cnt > trial_pause_time
                state = 'target';
                targ = targ_y_pos(1);
                targ_y_pos = targ_y_pos(2:end);
                
                if sum(targ==targ_exc) >0
                    trial_pause_time = exc_pause_time;
                else
                    trial_pause_time = pause_time;
                end
                
            else
                neut_cnt = neut_cnt+1;
            end
        end
        if strcmp(state,'target')
            curs = decoded_curs(c);
            curs = curs - (targ_locs(c)*asst/100)+(targ*asst/100);
            %curs = (curs - (targ_locs(c)*asst/100))*(1/((100-asst)/100));
            d = abs(curs - targ);
            timeout_cnt = timeout_cnt + 1;
            if d < target_radius
                rew(s) = rew(s)+1;
                ix = find(tg(:,1)==targ);
                rew_cnt(s, tg(ix,2)) = rew_cnt(s, tg(ix,2))+1;
                rew_time{s, tg(ix,2)} = [rew_time{s, tg(ix,2)} c];
                time2targ{s, tg(ix,2)} = [time2targ{s, tg(ix,2)} timeout_cnt];
                state = 'neutral';
                neut_cnt = 1;
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

rew_sim_act = rew(simN);



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

    function targ_y_pos = three_targ_co_gen(n_targets)
        block = 2;
        y = [-6, 6]';
        Y = repmat(y, [block, 1]);
        n_reps = round(n_targets/(2*block));
        
        targ_y_pos = [];
        for i = 1:n_reps
            idx_shuff = randperm(block*2);
            for j = 1:length(idx_shuff)
                targ_y_pos = [targ_y_pos; Y(idx_shuff(j)); 0];
            end
        end
    end

end