function plot_targs(blocks, date, tslice, tslice_opt, trim_n_targs, rem_targ_faster_than_n_secs)

% Inputs: See 'concat_dat_gen' for description / format of inputs

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew] = concat_dat_gen(blocks, date, tslice, tslice_opt, trim_n_targs);

%Target Color Map:
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
time2targ_save = {};
%Time to targets:
%Take rew_inds, find previous rew_ind, add 4 for reward length

%Reach Time for Rewarded Targets: 
reach_time = [REW(1)];
for i=2:length(REW)
    rt = REW(i) - (REW(i-1)+4);
    reach_time = [reach_time rt];
end
reach_time = time2rew*(.4); 

%Path length
dcurs = abs(diff(CURS));
path_length = [sum(dcurs(REW(1)-1))];
for i=2:length(REW)
    pl = sum(dcurs(REW(i-1)+4:(REW(i)-1)));
    path_length = [path_length pl];
end

%Prin

%Plots by Target:
targ_loc = TARG(REW);
targs = unique(targ_loc);
print_targs = 1:length(targs);

figure(1); figure(2);
subplot(2,2,1)

rew_time = REW*.4;
idx_time = idx*.4;

for i=1:length(targs)
    ix = find(targ_loc==targs(i));
    rch_t = reach_time(ix);
    t_t = rew_time(ix);
    
    if rem_targ_faster_than_n_secs > 0
        ix_n = rch_t > rem_targ_faster_than_n_secs;
    else
        ix_n = 1:length(rch_t);
    end
    
    %Figure 1, Reward Time
    figure(1);
    subplot(4,1 ,i)
    plot(t_t(ix_n)/60, rch_t(ix_n),'.','color',cmap{i},'markersize', 20)
    disp(strcat('Target: ',num2str(targs(i)), ' Mean: ',...
        num2str(mean(rch_t(ix_n))), 'SEM: ', num2str(std(rch_t(ix_n))/sqrt(length(ix_n)))))
    time2targ_save{targs(i)+7} =  rch_t(ix_n);
    
    mx= max(rch_t(ix_n));
    %legend(['Target ' num2str(targs(i))])
    hold on
    ylabel('Reach Time, sec.')
    xlabel('Time, Min.')
    if length(ix_n) > 1
        linfit  = regstats(rch_t(ix_n), t_t(ix_n)/60,'linear');
        pv_slope = linfit.tstat.pval(2);
    
        xhat = 0:max(t_t(ix_n))*1.1/60;
        yhat = linfit.beta(1)+linfit.beta(2)*xhat;
        hold on;
        plot(xhat, yhat, '--', 'linewidth', 2,'color', cmap{i})
    end
    xlim([0, (max(t_t)*1.1)/60])
    ylim([0, max(rch_t(ix_n))*1.1])
    try
        title(['Target ' num2str(targs(i)) ': p = ' num2str(round(pv_slope*1000)/1000) ' slp=' num2str(linfit.beta(2))])
    catch
        title(['Target ' num2str(targs(i))])
    end
    xl = get(gca,'XLim');
    set(gca,'XLim',[0 xl(2)])
    
    
    %Figure 2, First 5 min, last 5 min:
    xx = rch_t(ix_n);
    n_tg = floor(length(xx)/2);
    
    early_ix = 1:n_tg;
    late_ix = (length(xx)-n_tg+1):length(xx);
    
    early = xx(early_ix);
    late = xx(late_ix);
    [h, p2, ci, stats] = ttest2(early, late);
    
    figure(99);
    hold all
    subplot(2,2,i);
    try
        boxplot([early late], [zeros(1,length(early)), ones(1,length(late))],'labels',{'early','late'})
    catch
        disp('x')
        p2 = nan;
    end
    title(['p = ' num2str(p2)])
    xlim([0, 3])
    
    %Figure 2, Path Length
%     figure(2);
%     subplot(2,2,i)
%     hold on
%     plot(rew_time(ix),path_length(ix),'.','color',cmap{i})
%     legend(['Target ' num2str(targs(i))])
%     
%     linfit  = regstats(path_length(ix),rew_time(ix),'linear');
%     pv_slope = linfit.tstat.pval(2);
%     title(['p = ' num2str(pv_slope)])
%     
%     ylabel('Path Length, Screen Units')
%     xlabel('Time, sec.')
    
end

save(strcat('time2targ_', date, blocks, '.mat'),'time2targ_save')

end
% 
% function lin_reg(x,y,ax)
%     %Fit linear regression:
%     p = polyfit(x,y,1);
%     t = 1:round(x(end));
%     yt = polyval(p, t);
%     plot(ax,t,yt,'k-')
% 
%     ypred = polyval(p,x);
%     yresid = y - ypred;
%     SSresid = sum(yresid.^2);
%     SStotal = (length(y)-1) * var(y);
%     rsq = 1 - SSresid/SStotal;
%     title(['R^2: ' num2str(rsq) ' p-val: ' num2str(])
% end
% 
