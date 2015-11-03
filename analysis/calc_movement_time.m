function [rch_abs_time, targ_inds, tm_bound, targ_start_abs_time] = calc_movement_time(blocks, day)

    cmap4 = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
    cmap3 = {[70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
    figure(99); hold all;
    
    [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state,ix_bound] = parse_dat(blocks, day);
    tm_bound = abs_t(ix_bound);
    targ_inds = targ(rew_inds);
    targ_unique = unique(targ_inds);
    targ_unique = targ_unique(abs(targ_unique)>0);
    if length(targ_unique)==3
        cmap = cmap3;
    elseif length(targ_unique)==4
        cmap = cmap4;
    end
    rch_time = zeros(length(targ_inds),1);
    rch_abs_time = zeros(length(targ_inds),1);
    targ_start_abs_time = zeros(length(targ_inds),1);
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
            rch_abs_time(ting) = abs_t(targ_rew_ix(t)) - abs_t(targ_rew_ix(t)-ix+1);
            rch_ix = [rch_ix rch_abs_time(ting)];
            targ_start_abs_time(ting) = abs_t(targ_rew_ix(t)-ix+1);
            try
                curs_targ(t,:) = curs(targ_rew_ix(t)-4:targ_rew_ix(t));
            catch
                curs_targ(t,5-targ_rew_ix(t)+1:end) = curs(1:targ_rew_ix(t));
            end
        end
        curs_cell{i} = curs_targ;
        
        figure(99)
        plot(abs_t(targ_rew_ix)/60, rch_ix, '.', 'color',cmap{i})
        xlabel('Time in Block (min)')
        ylabel('Target Acquistion Time(sec)')
        
        figure(98); hold all;
        curs_mn =  mean(curs_cell{i}, 1);
        plot(1:5, curs_mn, '.-','color', cmap{i})
        
        sem = std(curs_cell{i},0,1)/sqrt(size(curs_cell{i},1));
        
        p = fill([1:5 5:-1:1], [curs_mn-sem, fliplr(curs_mn)+sem], cmap{i});
        set(p,'FaceAlpha',.3)
        set(p,'EdgeAlpha',0)
        
        xlabel('Time (.4 sec steps)')
        ylabel('Cursor')
        
    end
    figure(99);
    for j = 1:length(ix_bound)
        ix = ix_bound(j);
        plot([abs_t(ix)/60, abs_t(ix)/60], [0, 24],'--',...
            'color',[0.75 0.75 0.75],'linewidth',4)
    end
    
end

