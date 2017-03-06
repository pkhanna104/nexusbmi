function h00 = spec_dist_gen(blocks, date, tslice, tslice_opt, trim_n_targs,...
    low_high, daycol)

% Inputs: See 'concat_dat_gen' for description / format of inputs
[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

spec_vect_main = {};
if sum(TARG==0) > 4
    targ_locs = [-6 0 6];
else
    %targ_locs = sort(unique(TARG(REW)));
    targ_locs = [-6 -2 2 6];
end

figure()

try
    if size(FT, 2) >= 3 && sum(FT(:,3))>0
        FT = FT(:,3);
        spec_plot = 1;
    else
        disp('using power channel as feature')
        FT = mean(pxx{1},1);
        FT(FT == 0) = nan;
        spec_plot = 0;
    end
    spec_plots_v1 = 1;
catch
    spec_plots_v1 = 0;
    spec_plot = 0;
end

cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

x = linspace(0,1,32);
cmap_imsc = flipud([ones(32, 1) x' x'; flipud(x') flipud(x') ones(32,1)]);

if spec_plots_v1
    %Spec Histograms
    bins = linspace(prctile(FT,5),prctile(FT,99),20);
    
    db = bins(2)-bins(1);
    dbstep = db/100;
    
    leg = {};
    for i = 1:length(targ_locs)
        hold on
        ix = find(TARG==targ_locs(i));
        if length(ix) > 0
            [n, x] = hist(FT(ix),bins);
            disp([num2str(i) 'mean: ' num2str(nanmean(FT(ix))) ', median: ' num2str(nanmedian(FT(ix)))]);
            norm_n = n/sum(n);
            %plot(gca,x+((i-1)*dbstep),norm_n, '.-','color',cmap{i},'LineWidth',3,'MarkerSize',30)
            %leg{length(leg)+1} = strcat('Targ: ', num2str(targ_locs(i)));
        end
    end
    xlabel('Beta Power','FontSize',20)
    ylabel('Frequency','FontSize',20)
    legend(leg)
    LEGH = legend;
    set(LEGH,'Location','northwest')
    
    %disp(['KLD, ' num2str(kl_div(nlow,nhigh))])
    %Beta Triggered Plots;
    % 5 iterations (5*.4 = 2 sec prior) to reward :
    figure(101); hold all;
    ft_stats = [];
    grp_stats = [];
    leg2 = {};
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
            ft_mat = zeros(length(align_ix), 6);
            for r = 1:length(align_ix)
                rw = align_ix(r);
                if rw>6
                    ft_mat(r,:) = FT(rw-5:rw);
                else
                    ft_mat(r,6-rw+1:end) = FT(1:rw);
                end
            end
            ft_mat(ft_mat==0) = nan;
            sem=nanstd(ft_mat,0, 1)/sqrt(size(ft_mat,1));% standa
            mn = nanmean(ft_mat, 1);
            
            t = [.4*-5:.4:0];
            h00 = errorbar(gca, t, mn-mn(1), sem,'color',daycol,'LineWidth',3,'MarkerSize',30)
            leg2{length(leg2)+1} = strcat('Targ: ', num2str(targ_locs(i)));
            ft_stats = [ft_stats; ft_mat];
            grp_stats = [grp_stats ones(1,size(ft_mat,1))+i];
        end
    end
    
    %STATS:
    
    for tt =1:6
        % Do only for darpa figure:
        ix1 = find(grp_stats==min(grp_stats));
        ix2 = find(grp_stats==max(grp_stats));
        [Hyp,TP,T_CI] = ttest2(ft_stats(ix1,tt), ft_stats(ix2, tt), 'tail', 'both');
        if Hyp==1
            disp('Signficant TTest b/w High and Low: ');
            disp(['P = ' num2str(TP)])
            disp(['Time point: ' num2str(tt)])
            disp('')
            disp('')
        end
        
        [p, anovatab, stats] = anova1(ft_stats(:,tt), grp_stats, 'off');
        if p <= .05
            if p <= .05 & p > .01
                plot(t(tt), 20, 'k*')
            elseif p<= .01 & p > .001
                plot([t(tt) t(tt)+.05], [20 20], 'k*')
            elseif p < .001
                plot([t(tt) t(tt)+.05 t(tt)+.1], [20 20 20], 'k*')
            end
            disp(strcat('P ANOVA: ', num2str(tt), '__', num2str(p*10000)))
        end
    end
    %END STATS
    
    legend(leg2,'Location','northwest')
    xlabel('Time Prior to Target Acquisition (sec)','FontSize',20)
    ylabel('Beta (10-20 Hz) Power','FontSize',20)
    LEGH = legend;
    set(LEGH,'Location','northwest')
    
end

%Spec triggered plots:

if spec_plot==1
    if sum(sum(RAW_stn)) == 0
        RAW = RAW_m1;
    else
        RAW = RAW_stn;
    end
    
    f = figure(999);
    colormap(f, cmap_imsc)
    figure(998)
    flim = 50;
    hold on
    params = struct();
    params.Fs = 422;
    
    %
    % [Pxx,F] = pwelch(X,WINDOW,NOVERLAP,NFFT,Fs) ret
    [S, f] = pwelch(rand(169,1), 128, 0, 128, params.Fs);
    
    dat = RAW(:,1:168);
    baseline = zeros(size(dat,1), length(f));
    for i = 1:size(dat,1)
        if sum(dat(i,1:168))>0
            [S, f] = pwelch(dat(i,1:168)', 128, 0, 128, params.Fs);
            baseline(i, :) = S;
        else
            baseline(i,:) = nan;
        end
    end
    
    baseline_mu =  nanmean(baseline, 1);
    baseline_std = nanstd(baseline, 0, 1);
    
    %[S, f] = mtspectrumc(zeros(168,6),params);
    t = [.4*-5:.4:0];
    mximm = [];
    mnimm = [];
    fr_z ={};
    for i = 1:length(targ_locs)
        
        figure(999)
        subplot(1,4,i)
        rw_ix = find(TARG(REW)== targ_locs(i));
        if ~isempty(rw_ix)
            raw_mat = zeros(length(rw_ix), 6, 168);
            spec_mat = zeros(length(rw_ix), 6, length(f));
            spec_vect = zeros(length(rw_ix), length(f));
            
            for r = 1:length(rw_ix)
                rw = REW(rw_ix(r));
                if rw >5
                    dat = RAW(rw-5:rw,1:168);
                else
                    dat = zeros(6,168);
                    dat(6-rw+1:end,:) = RAW(1:rw, 1:168);
                end
                
                raw_mat(r,:,:) = dat;
                %[Sind, f_i] = mtspectrumc(dat', params);
                for ixx = 1:size(spec_mat, 2)
                    if sum(dat(ixx,:)) == 0
                        spec_mat(r,ixx,:) = nan;
                    else
                        [Sind, f_i] =  pwelch(dat(ixx,:), 128, 0, 128, params.Fs);
                        spec_mat(r,ixx,:) = Sind;
                    end
                end
                spec_vect(r,:) = squeeze(mean(spec_mat(r, end-1:end, :),2));
            end
            
            mn = squeeze(nanmean(spec_mat, 1));
            zsc = (mn(:,f<flim)' - repmat(baseline_mu(f<flim)', [1 size(mn, 1)]))./repmat(baseline_std(f<flim)', [1 size(mn, 1)]);
            
            imagesc(t, f(f<flim), zsc);
            mximm = [mximm max(max(zsc))];
            mnimm = [mnimm min(min(zsc))];
            
            title(['Targ: ' num2str(targ_locs(i))])
            xlabel('Time Before Reward (sec)')
            ylabel('Frequency (Hz)')
            if i==4
                %colorbar()
            end
            
            franges = {[0, 5],[5, 10], [10, 30], [30, 50], [50, 200]};
            
            figure(998)
            subplot(length(franges),1,1)
            hold on;
            
            
            
            for fr = 1:length(franges)
                subplot(length(franges), 1, fr)
                hold on;
                fr_ix = find(f_i>franges{fr}(1) & f_i<=franges{fr}(2));
                
                range_spec = sum(spec_mat(:,:,fr_ix), 3);
                base_mean = nanmean(sum(baseline(:,fr_ix),2));
                base_std = nanstd(sum(baseline(:,fr_ix), 2));
                
                zsc = (range_spec - base_mean)/base_std;
                
                sem=nanstd(zsc,0, 1)/sqrt(size(spec_mat,1));% standa
                mn = nanmean(zsc, 1);
                t = [.4*-5:.4:0];
                errorbar(t, mn, sem,'color',cmap{i},'LineWidth',3,'MarkerSize',30)
                fr_z{fr, i} = zsc;
            end
            
            figure(997)
            hold on;
            spec_vect_main{i}=spec_vect;
            z = mean(spec_vect,1);
            b_mean = nanmean(baseline, 1);
            b_std = nanstd(baseline, 0 , 1);
            
            sem = nanstd(spec_vect-repmat(b_mean, size(spec_vect, 1), 1))/sqrt(size(spec_vect, 1));
            zsc = (z - b_mean)./(b_std);
            ix = 1:length(z);
            if i==low_high(1) || i==low_high(2)
                plot(f(ix), zsc(ix),'color',cmap{i},'LineWidth',3,'MarkerSize',30)
                %errorbar(f(ix), zsc(ix), sem(ix),'color',cmap{i},'LineWidth',3,'MarkerSize',30)
            end
            
            if i==4
                ks = [];
                for jj=1:length(f)
                    ks = [ks kstest2(spec_vect_main{low_high(1)}(:,jj), spec_vect_main{low_high(2)}(:,jj))];
                end
                sig = find(ks==1);
                if length(sig) > 0
                    plot(f(sig), zeros(length(sig),1), 'k*')
                else
                    disp('no sig')
                end
            end
            
            %legend('Targ_y: -6','Targ_y: -2','Targ_y: 2','Targ_y:6')
        end
    end
    
    figure(999)
    tight_subplot(1,4,.1, .1, .1)
    for i = 1:length(targ_locs)
        subplot(1,4,i)
        set(gca, 'CLim', [-2, 2]);
    end
    
    figure(998)
    for fr=1:length(franges)
        spec = [];
        grp = [];
        for itarg = 1:length(targ_locs)
            zsc = fr_z{fr, itarg};
            spec = [spec; zsc];
            grp = [grp (itarg+ones(1,size(zsc,1)))];
        end
        subplot(length(franges), 1, fr)
        hold on;
        ax = gca;
        ylm = get(ax, 'YLim');
        ylim([ylm(1) 2.1])
        for t_i = 1:size(zsc, 2)
            [p, anovatab, stats] = anova1(spec(:,t_i), grp, 'off');
            if p <= .1 && p > .05
                plot(t(t_i), 2, 'r*')
                
            elseif p <= .05
                plot(t(t_i), 2, 'r*')
                plot(t(t_i)+.05, 2, 'r*')
            else
                p = kruskalwallis(spec(:,t_i), grp, 'off');
                if p<=.1
                    plot(t(t_i), 2.1, 'b*')
                end
            end
        end
        title(strcat(' Range: ', num2str(franges{fr}(1)), '-', num2str(franges{fr}(2))))
    end
    
end
end
