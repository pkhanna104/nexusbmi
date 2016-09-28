function plot_beta_as_fcn_of_time(blocks, date, tslice, tslice_opt,...
    trim_n_targs, rem_targ_faster_than_n_secs)

%% Dates / time started & times of medication
TOD = struct();
TOD.d0517.tod = 11;
TOD.d0517.tsm = 4;

TOD.d0518.tod = 10.25;
TOD.d0518.tsm = 2.25;

TOD.d0519.tod = 11;
TOD.d0519.tsm = 4;

TOD.d0520.tod = 9.5;
TOD.d0520.tsm = 2.5;

TOD.d0523.tod = 9.5;
TOD.d0523.tsm = 2.5;

TOD.d0524.tod = 11;
TOD.d0524.tsm = 3.5;

TOD.d0530.tod = 10;
TOD.d0530.tsm = 2.5;

TOD.d0608.tod = 9.5;
TOD.d0608.tsm = 2.5;

mins_per_epoch = 5;
figure()
ax1 = subplot(2, 1, 1);
hold all
ax2 = subplot(2, 1, 2);
hold all
%% Extract beta data: 
[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len, bool_rt] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%% Plot avg beta  %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c_idx = cumsum(idx);
bl_len =[];
for i_d = 1:length(date)
    bl_len(i_d) = length(blocks{i_d});
end
c_idx_day_start = cumsum(bl_len);
c_idx_day_start_v2 = [0 c_idx_day_start];
c_idx_v2 = [0 c_idx];

epoch_step = round(mins_per_epoch*60/0.4);

for i_d = 1:length(c_idx_day_start_v2) - 1
    blocks_in_day = (c_idx_day_start_v2(i_d)+1):c_idx_day_start_v2(i_d+1);
    day_st = c_idx_v2(blocks_in_day(1))+1;
    day_end = c_idx_v2(blocks_in_day(end)+1);
    epoch_ix = day_st:epoch_step:day_end;
    avg_beta_power = [];
    
    D = date{i_d};
    
    for e=1:length(epoch_ix(1:end-1))
        avg_beta_power(e) = mean(mean(FT(epoch_ix(e):epoch_ix(e+1), :)));
    end
    
    tod = TOD.(strcat('d', num2str(D(1:4)))).tod; %In hours
    tsm = TOD.(strcat('d', num2str(D(1:4)))).tsm; %In hours
    t_ax = 0:mins_per_epoch:((day_end-day_st)*.4/60);
    
    plot(ax1, (t_ax(1:end-1)/60)+tod, avg_beta_power)
    plot(ax2, (t_ax(1:end-1)/60)+tsm, avg_beta_power)
end

legend(ax1, date)
legend(ax2, date)
xlabel(ax1, 'Mean Beta Power as function of Time of Day (A.M.)')
xlabel(ax2, 'Mean Beta Power as a function of Time Since last Med Does (hrs)')
ylabel(ax1, 'Mean Beta Pwr, (windows of 5 min)')
ylabel(ax2, 'Mean Beta Pwr, (windows of 5 min)')
