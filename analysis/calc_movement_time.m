function [rch_time, targ_inds] = calc_movement_time(block, day)

    cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
    figure(99); hold all;
    
    [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state] = parse_dat(block, day);

    targ_inds = targ(rew_inds);
    targ_unique = unique(targ_inds);
    rch_time = zeros(length(targ_inds),1);
    
    curs_cell = {};
    
    %Calculate time to movement
    for i=1:length(targ_unique)
        tmp = find(targ_inds==targ_unique(i));
        targ_rew_ix = rew_inds(tmp);
        rch_ix = [];
        curs_targ = zeros(length(targ_rew_ix), 5);
        
        %Step backward from rew_ind to get time of 'wait' 
        for t = 1:length(targ_rew_ix)
            srch = 1;
            ix = 0;
            while srch
                if strcmp(state{targ_rew_ix(t)-ix}, 'wait')
                    srch = 0;
                    rch = ix;
                else
                    ix = ix + 1;
                end
            end
            ting = find(rew_inds==targ_rew_ix(t));
            rch_time(ting) = rch;
            rch_ix = [rch_ix rch];
            curs_targ(t,:) = curs(targ_rew_ix(t)-4:targ_rew_ix(t));
        end
        curs_cell{i} = curs_targ;
        
        figure(99)
        plot(targ_rew_ix, rch_ix, '.-', 'color',cmap{i})
        xlabel('Task Iteration')
        ylabel('Iteration Times')
        
        figure(98); hold all;
        plot(1:5, mean(curs_cell{i}, 1), '.-','color', cmap{i})
        xlabel('Time (.4 sec steps)')
        ylabel('Cursor')
        
    end
    
end

