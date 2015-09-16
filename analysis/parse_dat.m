function [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds] = parse_dat(blocks, day)

    %Get times, and target onsets;
    % blocks = 'ab';
    % day = '091615';

    %Find data path:
    [label paths] = textread('config.txt', '%s %s',5);
    if strcmp(label{4},'dat')
        dir = paths{4};
    end


    ft = []; raw_td_m1 = []; raw_td_stn = []; raw_pxx = []; abs_t=[]; targ=[];
    curs=[]; rew_inds = [];

    for ai = 1:length(blocks)
        alpha = blocks(ai);
        dat_fname = ['dat' day alpha '_.mat'];
        load(dat_fname)
        iter_cnt = dat.iter_cnt - 1;

        ft = [ft; dat.features(1:iter_cnt,3)];
        raw_td_m1 = [raw_td_m1; dat.rawdata_timeseries_m1(1:iter_cnt,1:169)];
        raw_td_stn = [raw_td_stn; dat.rawdata_timeseries_stn(1:iter_cnt,1:169)];

        px1 = dat.rawdata_power_ch2(:);

        for p=1:length(px1)
            if isempty(px1{p})
                px1{p} = [-1];
            end
        end

        px2 = dat.rawdata_power_ch4(:);
        for p=1:length(px2)
            if isempty(px2{p})
                px2{p} = [-1];
            end
        end

        px1_mat = cell2mat(px1);
        px2_mat = cell2mat(px2);

        raw_pxx = [raw_pxx; [px1_mat(1:iter_cnt) px2_mat(1:iter_cnt)] ];
        abs_t = [abs_t; dat.abs_time'];

        prev_len = length(targ);
        targ = [targ; dat.target(1:iter_cnt)];
        curs = [curs; dat.cursor(1:iter_cnt)];
        rew_inds = [rew_inds dat.reward_times{1}+prev_len];
    end
end

