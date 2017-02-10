function beta_desynch_tapping(blocks, date, tslice, tslice_opt, trim_n_targs,...
    low_high, daycol)

% Inputs: See 'concat_dat_gen' for description / format of inputs
[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

figure(101); hold all;
ft_stats = [];
grp_stats = [];
leg2 = {};
disp('using power channel as feature')
FT = mean(pxx{1},1);
FT(FT == 0) = nan;
spec_plot = 0;
targ_locs = [-6 0 6];

for i = 1:length(targ_locs)
    if strcmp(task, 'target_task')
        rw_ix = find(TARG(REW)== targ_locs(i));
        align_ix = REW(rw_ix);
    elseif strcmp(task, 'target_tapping')
        ix_ = find(trial_outcome(:,3)==9);
        rw_ix = find(TARG(trial_outcome(ix_,1))==targ_locs(i));
        align_ix = trial_outcome(ix_(rw_ix), 1)+targ_len(ix_(rw_ix))';
    elseif strcmp(task, 'finger_tapping')
        ix_ = find(trial_outcome(:,3)==9);
        rw_ix = find(TARG(trial_outcome(ix_,1))==targ_locs(i));
        align_ix = trial_outcome(ix_(rw_ix), 4); %+targ_len(ix_(rw_ix))';
    end
    
    if ~isempty(align_ix)
        ft_mat = zeros(length(align_ix), 19);
        for r = 1:length(align_ix)
            rw = align_ix(r);
            if and(rw > 10, rw<length(FT)-9)
                ft_mat(r,:) = FT(rw-9:rw+9);
            elseif rw > (length(FT)-9)
                ft_mat(r,1:length(FT(rw-9:end))) = FT(rw-9:end);
            elseif rw < 10
                ft_mat(r,end -length(FT(1:rw+9))+1:end) = FT(1:rw+9);
            end
        end
        ft_mat(ft_mat==0) = nan;
        sem=nanstd(ft_mat,0, 1)/sqrt(size(ft_mat,1));% standa
        mn = nanmean(ft_mat, 1);
        t = [-.4*9:.4:.4*9];
        
        errorbar(gca, t, mn -mn(end), sem,'color',daycol,'LineWidth',3,'MarkerSize',30)
    end
end
end
