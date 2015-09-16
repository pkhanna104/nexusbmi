function calc_movement time(block, day)

    [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds] = parse_dat(block, day);

    targ_inds = targ(rew_inds);
    targ_unique = unique(targ_inds);
    
    %Calculate time to movement
    for i=1:length(targ_unique)
        
        tmp = find(targ_inds==targ_unique(i));
        targ_rew_ix = rew_inds(tmp);
        
        for t = 1:length(targ_rew_ix)
            C = [C; curs(targ_rew_ix(t)-5:targ_rew_ix)];
        end
    end
end



