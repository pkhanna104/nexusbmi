function [nf_time2targ_save, bool_rt_save] = plot_targs(blocks, date, tslice, tslice_opt,...
    trim_n_targs, rem_targ_faster_than_n_secs)

% Inputs: See 'concat_dat_gen' for description / format of inputs
%Target Color Map:
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len, bool_rt, timeout_tm] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

%Ranges of bool_rts: 
rew_ix = find(trial_outcome(:,3)==9);
bool_rt_rgs = {[.1, .5], [.5, .9], [.9, 1.2], [1.2, 1.6]};
prob_low_targ = {};
for b=1:length(bool_rt_rgs)
    rng = bool_rt_rgs{b};
    ix = find(and(bool_rt(rew_ix)>= rng(1), bool_rt(rew_ix)<rng(2)));
    
    targs = trial_outcome(rew_ix(ix), 2);
    low = length(find(targs==-6));
    high = length(find(targs==6));
    p = myBinomTest(low, low+high, .5, 'two');
    prob_low_targ{b} = [p, low/(low+high), low+high];
end

%PRINT: 
if strcmp(task, 'target_tapping')
    prob_low_targ{:}

    %Bool RT vs. Targ Len: 

    figure()
    low_rew = find(trial_outcome(rew_ix, 2)==-6);
    high_rew = find(trial_outcome(rew_ix, 2)==6);
    plot(targ_len(rew_ix(low_rew)), bool_rt(rew_ix(low_rew)), '.', 'color', cmap{1})
    hold on;
    plot(targ_len(rew_ix(high_rew)),bool_rt(rew_ix(high_rew)),  '.', 'color', cmap{3})
    linfit  = regstats(bool_rt(rew_ix), targ_len(rew_ix),'linear');
    xhat = 0:120;
    yhat = linfit.beta(1)+linfit.beta(2)*xhat;
end

nf_time2targ_save = {};
perc_corr_save = {};

%Time to targets:
%Take rew_inds, find previous rew_ind, add 4 for reward length

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Plot percent correct by target %%%%%%%%%:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mins_per_epoch = 5;
epoch_step = round(mins_per_epoch*60/0.4);
end_ = trial_outcome(end, 1);
epoch_ix = 1:epoch_step:end_;

unique_targs = sort(unique(trial_outcome(:,2)));
perc_corr = zeros(length(unique_targs), length(epoch_ix)-1);
avg_beta_power = zeros(length(epoch_ix)-1, 2);

for e=1:length(epoch_ix(1:end-1))
    P1 = pxx{1}(:, epoch_ix(e):epoch_ix(e+1));
    P1(P1 == 0) = nan;
    P2 = pxx{2}(:, epoch_ix(e):epoch_ix(e+1));
    P2(P2 == 0) = nan;
    
    avg_beta_power(e, 1) = nanmean(unrav(P1));
    avg_beta_power(e, 2) = nanmean(unrav(P2));
    
    time_ix = find(and(trial_outcome(:,1)<=epoch_ix(e+1), trial_outcome(:,1)>epoch_ix(e)));
    
    for t=1:length(unique_targs)
        targ_ix = find(trial_outcome(time_ix,2)==unique_targs(t));
        if ~isempty(targ_ix)
            outcome = trial_outcome(time_ix(targ_ix), 3);
            if abs(unique_targs(t)) > 0
                perc_corr(t, e) = length(outcome(outcome==9))/length(outcome);
            elseif unique_targs(t) == 0
                perc_corr(t, e) = length(outcome(outcome==15))/length(outcome);
            end
        end
    end
end
time_ax = epoch_ix*0.4/(60);

figure(123);
subplot(2,1,1);
lab = {};
for t=1:length(unique_targs)
    plot(gca, time_ax(1:end-1), perc_corr(t,:), '-', 'color', cmap{t},...
        'linewidth', 3);
    hold on;
    lab{t} = strcat('Targ: ', num2str(unique_targs(t)));
end

c_idx = cumsum(idx);
bl_len =[];
for d = 1:length(date)
    bl_len(d) = length(blocks{d});
end
c_idx_day_start = cumsum(bl_len);

for t=1:length(c_idx)
    t1 = c_idx(t)*0.4/60
    if ~isempty(find(c_idx_day_start==t))
        plot(gca, [t1, t1], [0, 1], 'k-','linewidth',5)
    else
        plot(gca, [t1, t1], [0, 1], 'k--')
    end
end

legend(lab);
xlabel('Time in Minutes')
ylabel(strcat('Percent Correct in ', num2str(mins_per_epoch), ' min. Epochs'))
ylim([-.1, 1.1])

subplot(2, 1, 2)
hold on;
plot(time_ax(1:end-1), avg_beta_power)
xlabel('Time in Minutes')
ylabel(strcat('Avg. Beta Power in ', num2str(mins_per_epoch), ' min. Epochs'))
legend('M1', 'STN')
subplot(2, 1, 2)

for t=1:length(c_idx)
    t1 = c_idx(t)*0.4/60;
    if ~isempty(find(c_idx_day_start==t))
        plot(gca, [t1, t1], [0, 600], 'k-','linewidth',5)
    else
        plot(gca, [t1, t1], [0, 600], 'k--')
    end
end

ylim([400, 1025])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Neurofeedback Reach Time for Rewarded Targets: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(task, 'target_task')
    reach_time = [REW(1)];
    for i=2:length(REW)
        rt = REW(i) - (REW(i-1)+4);
        reach_time = [reach_time rt];
    end
    reach_time = time2rew*(.4);
    targ_loc = TARG(REW);
    
elseif strcmp(task, 'target_tapping')
    ix__ = find(trial_outcome(:,3)==9);
    reach_time = 0.4*targ_len(ix__);
    targ_loc = trial_outcome(ix__, 2);
    tapping_time = ((REW - trial_outcome(ix__,1)' - targ_len(ix__))*.4);
    bool_rt_trunc = bool_rt(ix__);
    outcome = trial_outcome(ix__, :);
    
elseif strcmp(task, 'finger_tapping')
    ix__ = find(or(trial_outcome(:, 3) == 9, trial_outcome(:, 3) == 12));
    reach_time = 0.4*targ_len(ix__);
    targ_loc = trial_outcome(ix__, 2);
    outcome = trial_outcome(ix__, :);
end

% %Path length
% dcurs = abs(diff(CURS));
% path_length = [sum(dcurs(REW(1)-1))];
% for i=2:length(REW)
%     pl = sum(dcurs(REW(i-1)+4:(REW(i)-1)));
%     path_length = [path_length pl];
% end

%Plots by Target:
targs = unique(targ_loc);
print_targs = 1:length(targs);

figure(1); figure(2);
subplot(2,2,1)

rew_time = REW*.4;
idx_time = idx*.4;
day_ixs = {};
f2axs_flag = false;
f3axs_flag = false;
bool_rt_save = {};
tapping_time_save = {};
tapping_time_day_save = {};

for i=1:length(targs)
    ix = find(targ_loc==targs(i));
    out = outcome(ix, :);
    
    ixr = find(out(:, 3) == 9);
    ixt = find(out(:,3) == 12);
    
    rch_t = reach_time(ix);
    
    if strcmp(task, 'target_tapping')
        tp_t = tapping_time(ix);
        bl_t = bool_rt_trunc(ix);
    end
    
    out2 = outcome(outcome(:, 3) == 9, :);
    ix0 = find(out2(:, 2) == targs(i));
    assert(length(ixr) == length(ix0));
    t_r = rew_time(ix0);
    
    t_o = .4*(out(ixt, 1) - (rch_t(ixt)/.4)');
    
    t_t = zeros(length(ix), 1);
    t_t(ixr) = t_r;
    t_t(ixt) = t_o;
    
    if rem_targ_faster_than_n_secs > 0
        ix_n = rch_t > rem_targ_faster_than_n_secs;
    else
        ix_n = 1:length(rch_t);
    end
    
    %%%%%%%%% Save Perc. Corr. By Targ %%%%%
%     mins_per_epoch = 5;
%     epoch_step = round(mins_per_epoch*60/0.4);
%     end_ = trial_outcome(end, 1);
%     epoch_ix = 1:epoch_step:end_;
%     
%     unique_targs = sort(unique(trial_outcome(:,2)));
%     perc_corr = zeros(length(unique_targs), length(epoch_ix)-1);
%     avg_beta_power = zeros(length(epoch_ix)-1, 1);
%     
%     for e=1:length(epoch_ix(1:end-1))
%         avg_beta_power(e) = mean(mean(FT(epoch_ix(e):epoch_ix(e+1), :)));
%         time_ix = find(and(trial_outcome(:,1)<=epoch_ix(e+1), trial_outcome(:,1)>epoch_ix(e)));
%         
%         for t=1:length(unique_targs)
%             targ_ix = find(trial_outcome(time_ix,2)==unique_targs(t));
%             if ~isempty(targ_ix)
%                 outcome = trial_outcome(time_ix(targ_ix), 3);
%                 perc_corr(t, e) = length(outcome(outcome==9))/length(outcome);
%             end
%         end
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Figure 1, NF Target Time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure(1);
    subplot(2, 1 ,i)
    plot(t_t(ix_n)/60, rch_t(ix_n),'.','color',cmap{i},'markersize', 20)
    hold on;
    out_ix = find(out(ix_n, 3) == 12);
    plot(t_t(ix_n(out_ix))/60, rch_t(ix_n(out_ix)),'k.','markersize', 15)
    
    disp(strcat('How long target is on: Target: ',num2str(targs(i)), ' Mean: ',...
        num2str(mean(rch_t(ix_n))), 'SEM: ', num2str(std(rch_t(ix_n))/sqrt(length(ix_n)))))
    nf_time2targ_save{i} =  rch_t(ix_n);
    ylim([0, 80])
    mx= max(rch_t(ix_n));
    %legend(['Target ' num2str(targs(i))])
    hold on
    ylabel('Reach Time, sec.')
    xlabel('Time, Min.')
    
    %Learning by total:
    if length(ix_n) > 1
        linfit  = regstats(rch_t(ix_n), t_t(ix_n)/60,'linear');
        pv_slope = linfit.tstat.pval(2);
        
        xhat = 0:max(t_t(ix_n))*1.1/60;
        yhat = linfit.beta(1)+linfit.beta(2)*xhat;
        hold on;
        plot(xhat, yhat, '-', 'linewidth', 2,'color', cmap{i})
        
        
        %Learning by DAY:
        c_idx_day_start_v2 = [0 c_idx_day_start];
        c_idx_v2 = [0 c_idx];
        
        for i_d = 1:length(c_idx_day_start_v2)-1
            blocks_in_day = (c_idx_day_start_v2(i_d)+1):c_idx_day_start_v2(i_d+1);
            
            day_st = c_idx_v2(blocks_in_day(1))+1;
            day_end = c_idx_v2(blocks_in_day(end)+1);
            
            %Times w/in day:
            t_t_back_to_ix = t_t(ix_n)/.4;
            day_rew_ix = find(and(t_t_back_to_ix<=day_end, t_t_back_to_ix>day_st));
            day_ixs{i, i_d} = day_rew_ix;
            
            if length(day_rew_ix) > 1
                linfit = regstats(rch_t(ix_n(day_rew_ix)), t_t(ix_n(day_rew_ix))/60, 'linear');
                
                xhat =  t_t(ix_n(day_rew_ix(1)))/60: t_t(ix_n(day_rew_ix(end)))/60;
                yhat2 = linfit.beta(1) + linfit.beta(2)*xhat;
                hold on;
                plot(xhat, yhat2, '--', 'linewidth', 2, 'color', cmap{i})
                
                %txt = strcat('slp pv: ', num2str(linfit.tstat.pval(2)));
                %text(mean(xhat), max(rch_t(ix_n)), txt)
            end
            
        end
    end
    
    xlim([0, (max(t_t)*1.1)/60])
    ylim([0, max(rch_t(ix_n))*1.1])
    try
        title(['Target ' num2str(targs(i))])% ': p = ' num2str(round(pv_slope*1000)/1000) ' slp=' num2str(linfit.beta(2))])
    catch
        title(['Target ' num2str(targs(i))])
    end
    xl = get(gca,'XLim');
    set(gca,'XLim',[0 xl(2)])
    
    for t=1:length(c_idx)
        t1 = c_idx(t)*0.4/60;
        if ~isempty(find(c_idx_day_start==t))
            plot(gca, [t1, t1], [0, 600], 'k-','linewidth',5)
        else
            plot(gca, [t1, t1], [0, 600], 'k--')
        end
    end
    
    %%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Figure 2, Tapping Time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(task, 'target_tapping')
        
        %%%%%%%%%%%% Line Plot: %%%%%%%%%%%%%
        figure(22)
        plot(t_t(ix_n)/60, tp_t(ix_n),'.','color',cmap{i},'markersize', 20)
        xlabel('Time, Min.')
        
        if length(ix_n) > 1
            linfit  = regstats(tp_t(ix_n), t_t(ix_n)/60,'linear');
            pv_slope = linfit.tstat.pval(2);
            
            xhat = 0:max(t_t(ix_n))*1.1/60;
            yhat = linfit.beta(1)+linfit.beta(2)*xhat;
            hold on;
            plot(xhat, yhat, '--', 'linewidth', 2,'color', cmap{i})
        end
        xlim([0, (max(t_t)*1.1)/60])
        ylim([0, max(tp_t(ix_n))*1.1])
        try
            title(['Target ' num2str(targs(i)) ': p = ' num2str(round(pv_slope*1000)/1000) ' slp=' num2str(linfit.beta(2))])
        catch
            title(['Target ' num2str(targs(i))])
        end
        xl = get(gca,'XLim');
        set(gca,'XLim',[0 xl(2)])
        
        for t=1:length(c_idx)
            t1 = c_idx(t)*0.4/60;
            if ~isempty(find(c_idx_day_start==t))
                plot(gca, [t1, t1], [0, 600], 'k-','linewidth',5)
            else
                plot(gca, [t1, t1], [0, 600], 'k--')
            end
        end
        
        %%%%%%%%%%%%  Box Plot option: %%%%%%%%%%%%%%%%
        figure(2);
        if f2axs_flag == true
            disp('T')
        else
            f2ax1 = subplot(1, 2, 1);
            hold on
            f2ax2 = subplot(1, 2, 2);
            hold on
            f2axs_flag = true;
        end
        
        hold on;
        boxplot(f2ax1, tp_t(ix_n),'colors',cmap{i},'boxstyle','filled',...
            'positions',[i]);
        
        tapping_time_save{i} = tp_t(ix_n);
        
        disp(strcat('Tapping Time: Target: ',num2str(targs(i)), ' Mean: ',...
            num2str(mean(tp_t(ix_n))), 'SEM: ', num2str(std(tp_t(ix_n))/sqrt(length(ix_n)))))
        
        ylabel(f2ax1, 'Tapping Time, sec.')
        %xlim([0, 4]);
        title(f2ax1, 'Tapping Time')
        
        %Boxplot by day:
        for i_d=1:length(day_ixs)
            boxplot(f2ax2, tp_t(ix_n(day_ixs{i_d})), 'colors', cmap{i}, 'boxstyle',...
                'filled', 'positions', [i_d + (i*.25)])
            tapping_time_day_save{i, i_d} = tp_t(ix_n(day_ixs{i_d}));
        end
        
        xlim(f2ax2, [0, 5])
        xlim(f2ax1, [0, 6])
        
        
        %%%%%%%%%%%%  Box Plot option for Bool RT: %%%%%%%%%%%%%%%%
        figure(3);
        if f3axs_flag == true
            disp('t2')
        else
            f3a1 = subplot(1, 2, 1);
            hold on
            f3a2 = subplot(1, 2, 2);
            hold on
            f3axs_flag = true;
        end
        
        bool_rt_save{i} = bl_t(ix_n);
        boxplot(f3a1, bl_t(ix_n),'colors',cmap{i},'boxstyle','filled',...
            'positions',[i]);
        disp(strcat('Bool RT: Target: ',num2str(targs(i)), ' Mean: ',...
            num2str(mean(bl_t(ix_n))), 'SEM: ', num2str(std(bl_t(ix_n))/sqrt(length(ix_n)))))
        ylabel('Bool Rxn Time, sec.')
        xlim([0, 4]);
        
        %Boxplot by day:
        for i_d=1:length(day_ixs)
            boxplot(f3a2, bl_t(ix_n(day_ixs{i_d})), 'colors', cmap{i}, 'boxstyle',...
                'filled', 'positions', [i_d + (i*.25)])
        end
        
        xlim(f3a2, [0, 5])
        xlim(f3a1, [0, 6])
        
    end
    %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %Figure 2, First Half, Second Half:
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %     xx = rch_t(ix_n);
    %     n_tg = floor(length(xx)/2);
    %
    %     early_ix = 1:n_tg;
    %     late_ix = (length(xx)-n_tg+1):length(xx);
    %
    %     early = xx(early_ix);
    %     late = xx(late_ix);
    %     [h, p2, ci, stats] = ttest2(early, late);
    %
    %     figure(99);
    %     hold all
    %     subplot(2,2,i);
    %     try
    %         boxplot([early late], [zeros(1,length(early)), ones(1,length(late))],'labels',{'early','late'})
    %     catch
    %         disp('x')
    %         p2 = nan;
    %     end
    %     title(['p = ' num2str(p2)])
    %     xlim([0, 3])
    %
    %     %Figure 2, Path Length
    %     %     figure(2);
    %     %     subplot(2,2,i)
    %     %     hold on
    %     %     plot(rew_time(ix),path_length(ix),'.','color',cmap{i})
    %     %     legend(['Target ' num2str(targs(i))])
    %     %
    %     %     linfit  = regstats(path_length(ix),rew_time(ix),'linear');
    %     %     pv_slope = linfit.tstat.pval(2);
    %     %     title(['p = ' num2str(pv_slope)])
    %     %
    %     %     ylabel('Path Length, Screen Units')
    %     %     xlabel('Time, sec.')
    
end

%Stats on boxplot:
% if strcmp(task, 'target_tapping')
%     dat = [bool_rt_save{1} bool_rt_save{3}];
%     grps = [zeros(length(bool_rt_save{1}),1); ones(length(bool_rt_save{3}),1)]';
%     P = kruskalwallis(dat, grps, 'on');
%     title(gca,'TIME TO COMPLETE TAPPING');
% end
%save(strcat('time2targ_', date, blocks, '.mat'),'time2targ_save')

%Stats on Tapping Time:
if strcmp(task, 'target_tapping')
    figure(2)
    
    %KS test across days;
    [H,P,KSSTAT] = kstest2(tapping_time_save{1}, tapping_time_save{3});
    if P <= 0.05
        plot(f2ax1, [1, 3], [22, 22], 'k-')
    else
        plot(f2ax1, 0, 0)
    end
    
    txt = strcat('kstest2: p = ', num2str(P));
    text(2, 25, txt)
    xlim([0, 4])
    for i_d=1:length(day_ixs)
        [H,P,KSSTAT] = kstest2(tapping_time_day_save{1, i_d}, tapping_time_day_save{3, i_d});
        
        if P <= 0.05
            plot(f2ax2, [i_d + (1*.25), i_d + (3*.25)], [22, 22], 'k-')
        else
            plot(f2ax2, 0, 0)
        end

        txt = strcat('kstest2: p = ', num2str(P));
        text(i_d + 2*.25, 25, txt)
    end
    xlim([1, 5])
    
    
end
end




    function lin_reg(x,y,ax)
        %Fit linear regression:
        p = polyfit(x,y,1);
        t = 1:round(x(end));
        yt = polyval(p, t);
        plot(ax,t,yt,'k-')
        
        ypred = polyval(p,x);
        yresid = y - ypred;
        SSresid = sum(yresid.^2);
        SStotal = (length(y)-1) * var(y);
        rsq = 1 - SSresid/SStotal;
        title(['R^2: ' num2str(rsq) ' p-val: '])
    end

