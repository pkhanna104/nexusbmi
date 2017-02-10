function extract_arduino_tapping_mets(blocks, date, tslice, tslice_opt, trim_n_targs,...
    Fs)

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

dat_ix_to_ard_ix_fcn = concat_dat_gen_arduino(blocks, date, idx, tslice,...
    tslice_opt, trim_n_targs, Fs);

%Plot acc X aligned to all go cues;
figure;
offs = 0;
offs2 = 0;
for trl = 1:length(trial_outcome)
    if trial_outcome(trl, 3) == 9 
        if trial_outcome(trl, 2) == 6
            ix = [trial_outcome(trl, 4):1:trial_outcome(trl, 5)];
            ard = dat_ix_to_ard_ix_fcn(ix);
            subplot(2, 1, 1); hold all;
            plot( ard(:, 6)+offs)
            offs = offs + 75;
        elseif trial_outcome(trl, 2) == -6
            ix = [trial_outcome(trl, 4):1:trial_outcome(trl, 5)];
            ard = dat_ix_to_ard_ix_fcn(ix);
            subplot(2, 1, 2); hold all;
            plot( ard(:, 6)+offs2)
            offs2 = offs2 + 75;
        end
        
    end
end
