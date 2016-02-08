function plot_subj1()

[FT, RAW, TARG, CURS, REW, idx] = concat_dat('cdefgh', [141,1],[0,4]);

cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

%Time to targets:
%Take rew_inds, find previous rew_ind, add 4 for reward length
reach_time = [REW(1)];
for i=2:length(REW)
    rt = REW(i) - (REW(i-1)+4);
    reach_time = [reach_time rt];
end
reach_time = reach_time*(.4); 

%Path length
dcurs = abs(diff(CURS));
path_length = [sum(dcurs(REW(1)-1))];
for i=2:length(REW)
    pl = sum(dcurs(REW(i-1)+4:(REW(i)-1)));
    path_length = [path_length pl];
end

%Plots by Target:
targ_loc = TARG(REW);
targs = unique(targ_loc);

figure(1); figure(2);
subplot(2,2,1)

rew_time = REW*.4;
idx_time = idx*.4;

for i=1:length(targs)
    ix = find(targ_loc==targs(i));
    
    %Figure 1, Reward Time
    figure(1);
    subplot(2,2,i)
    plot(rew_time(ix),reach_time(ix),'.-','color',cmap{i})
    mx= max(reach_time(ix));
    legend(['Target ' num2str(targs(i))])
    hold on
%     for j=1:length(idx_time)
%         plot([idx_time(j) idx_time(j)], [0, mx],'r-')
%     end
    ylabel('Reach Time, sec.')
    xlabel('Time, sec.')
    lin_reg(rew_time(ix),reach_time(ix),gca)
    xl = get(gca,'XLim');
    set(gca,'XLim',[0 xl(2)])
    
   
    
    %Figure 2, Path Length
    figure(2);
    subplot(2,2,i)
    hold on
    plot(rew_time(ix),path_length(ix),'.-','color',cmap{i})
    legend(['Target ' num2str(targs(i))])
%     for j=1:length(idx_time)
%         plot([idx_time(j) idx_time(j)], [0, mx],'r-')
%     end
    lin_reg(rew_time(ix),path_length(ix),gca)
    
    %linfit  = regstats(path_length(ix),rew_time(ix),'linear');
    
    ylabel('Path Length, Screen Units')
    xlabel('Time, sec.')
    
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
        title(['R^2: ' num2str(rsq)])
    end

end
