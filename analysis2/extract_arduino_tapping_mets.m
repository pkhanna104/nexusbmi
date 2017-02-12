function [MET, trial_outcome] = extract_arduino_tapping_mets(blocks, date, tslice, tslice_opt,...
    trim_n_targs, Fs)

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

dat_ix_to_ard_ix_fcn = concat_dat_gen_arduino(blocks, date, idx, tslice,...
    tslice_opt, trim_n_targs, Fs);

MET = struct();
%Plot acc X aligned to all go cues;
for trl = 1:length(trial_outcome)
    if trial_outcome(trl, 3) == 9
        
        % Indices in terms of dat files: 
        ix = [trial_outcome(trl, 4):1:trial_outcome(trl, 5)];
        ard = dat_ix_to_ard_ix_fcn(ix);
        gyr = ard(:, [9, 10, 11]);
        if sum(unrav(isnan(gyr)))==0
            metrics = tapping_metrics(gyr, Fs);
            MET.(['trl_', num2str(trl)]) = metrics;
        else
            disp('nah');
        end
    end
end
end
