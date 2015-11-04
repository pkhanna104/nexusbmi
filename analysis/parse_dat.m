function [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state,ix_boundaries] = parse_dat(blocks, day, start_it)

    %Get times, and target onsets;
    % blocks = 'ab';
    % day = '091615';

    %Find data path:
    [label paths] = textread('config.txt', '%s %s',5);
    if strcmp(label{4},'dat')
        dir = paths{4};
    end


    ft = []; raw_td_m1 = []; raw_td_stn = []; raw_pxx = []; abs_t=[0]; targ=[];
    curs=[]; rew_inds = []; state = [];ix_boundaries = [];

    for ai = 1:length(blocks)
        alpha = blocks(ai);
        dat_fname = ['dat' day alpha '_.mat'];
        load(dat_fname)
        try
            iter_cnt = dat.iter_cnt - 1;
        catch
            iter_cnt = length(dat.state);
        end
        dat.state{1} = 'wait';
        
        if ~isempty(start_it)
            itr_start = start_it(ai);
        else
            itr_start = 1;
        end
        
        state = [state; dat.state(itr_start:iter_cnt)];
        ft = [ft; dat.features(itr_start:iter_cnt,3)];
        raw_td_m1 = [raw_td_m1; dat.rawdata_timeseries_m1(itr_start:iter_cnt,1:169)];
        raw_td_stn = [raw_td_stn; dat.rawdata_timeseries_stn(itr_start:iter_cnt,1:169)];

        try
            px1 = dat.rawdata_power_ch2(1:end);

            for p=1:length(px1)
                if isempty(px1{p})
                    px1{p} = [-1];
                end
            end

            px2 = dat.rawdata_power_ch4(1:end);
            for p=1:length(px2)
                if isempty(px2{p})
                    px2{p} = [-1];
                end
            end

            px1_mat = cell2mat(px1);
            px2_mat = cell2mat(px2);

            raw_pxx = [raw_pxx; [px1_mat(itr_start:iter_cnt) px2_mat(itr_start:iter_cnt)] ];
        catch
            raw_pxx = [raw_pxx];
        end
        
        abs_t = [abs_t; abs_t(end)+ dat.abs_time(itr_start:iter_cnt)' - dat.abs_time(1)];
        prev_len = length(targ);
        
        try
            targ = [targ; dat.target(itr_start:iter_cnt)];
        catch
            [final_targ_locs, trim_rew_inds] = get_targ_loc(dat);
            targ = [targ; final_targ_locs(itr_start:iter_cnt)];
        end
        curs = [curs; dat.cursor(itr_start:iter_cnt)];
        rwix = find(dat.reward_times{1}>itr_start);
        rew_inds = [rew_inds dat.reward_times{1}(rwix)+prev_len];
        ix_boundaries = [ix_boundaries; length(targ)];
    end
    abs_t = abs_t(2:end);
end

