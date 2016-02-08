function spec_dist_gen(blocks, date, tslice, tslice_opt, trim_n_targs)

% Inputs: See 'concat_dat_gen' for description / format of inputs
[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, PXX_CHAN] = concat_dat_gen(blocks, date, tslice, tslice_opt, trim_n_targs);

targ_locs = sort(unique(TARG(REW)));
figure()

try
    if size(FT, 2) >= 3 && sum(FT(:,3))>0
        FT = FT(:,3);
    else
         disp('using power channel as feature')
        FT = PXX_CHAN(1,:);
    end
    spec_plots_v1 = 1;
catch
    spec_plots_v1 = 0;
end

cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

x = linspace(0,1,32); 
cmap_imsc = flipud([ones(32, 1) x' x'; flipud(x') flipud(x') ones(32,1)]);

if spec_plots_v1
    %Spec Histograms
    bins = linspace(prctile(FT,5),prctile(FT,95),20);

    db = bins(2)-bins(1);
    dbstep = db/100;

    
    for i = 1:length(targ_locs)
        hold on
        ix = find(TARG==targ_locs(i));
        [n, x] = hist(FT(ix),bins);
        disp([num2str(i) 'mean: ' num2str(mean(FT(ix))) ', median: ' num2str(median(FT(ix)))]);
        norm_n = n/sum(n);
        plot(gca,x+((i-1)*dbstep),norm_n, '.-','color',cmap{i},'LineWidth',3,'MarkerSize',30)
    end
    xlabel('Beta Power','FontSize',20)
    ylabel('Frequency','FontSize',20)
    legend('Targ: -6','Targ: -2','Targ: 2','Targ:6')
    LEGH = legend;
    set(LEGH,'Location','northwest')

    %disp(['KLD, ' num2str(kl_div(nlow,nhigh))])
    %Beta Triggered Plots;
    % 5 iterations (5*.4 = 2 sec prior) to reward :
    figure()
    hold on
    ft_stats = [];
    grp_stats = [];
    for i = 1:length(targ_locs)
        rw_ix = find(TARG(REW)== targ_locs(i));
        ft_mat = zeros(length(rw_ix), 6);
        for r = 1:length(rw_ix)
            rw = REW(rw_ix(r));
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
        errorbar(t, mn, sem,'color',cmap{i},'LineWidth',3,'MarkerSize',30)
        ft_stats = [ft_stats; ft_mat];
        grp_stats = [grp_stats ones(1,size(ft_mat,1))+i];
    end

     %STATS:
     
     for tt =1:6
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
    
    
    
    legend('Targ: 1','Targ: 2','Targ: 3','Targ: 4','Location','northwest')
    xlabel('Time Prior to Reward (sec)','FontSize',20)
    ylabel('Beta (10-20 Hz) Power','FontSize',20)
    LEGH = legend;
    set(LEGH,'Location','northwest')
end

%Spec triggered plots:
spec_plot = 1;
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
        raw_mat = zeros(length(rw_ix), 6, 168);
        spec_mat = zeros(length(rw_ix), 6, length(f));
        
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
        
        %legend('Targ_y: -6','Targ_y: -2','Targ_y: 2','Targ_y:6')
    end
    
    figure(999)
    tight_subplot(1,4,.1, .1, .1)
    for i = 1:length(targ_locs)
        subplot(1,4,i)
        set(gca, 'CLim', [-1, 1]);
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
