function spec_dist_subj1(alph,start_inds, rm_targs,spec_plot)
[FT, RAW, TARG, CURS, REW, idx] = concat_dat(alph, start_inds,rm_targs);

targ_locs = [-6,-2, 2, 6];
figure()

%Spec Histograms
bins = linspace(100,800,10);
db = bins(2)-bins(1);
dbstep = db/6;

%cmap = ['g','b','y','r'];
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
for i = 1:length(targ_locs)
    hold on
    ix = find(TARG==targ_locs(i));
    [n, x] = hist(FT(ix),bins);
    disp([num2str(i) 'mean: ' num2str(mean(FT(ix))) ', median: ' num2str(median(FT(ix)))]);
    norm_n = n/sum(n);
    plot(gca,x+((i-1)*dbstep),norm_n, '.-','color',cmap{i},'LineWidth',3,'MarkerSize',30)
end
xlabel('Beta Power (10-20 Hz)','FontSize',20)
ylabel('Frequency','FontSize',20)
legend('Targ: -6','Targ: -2','Targ: 2','Targ:6')
LEGH = legend;
set(LEGH,'Location','northwest')

low = FT(TARG==targ_locs(1));
high = FT(TARG==targ_locs(4));

nlow = hist(low, bins);
nhigh = hist(high, bins);

%disp(['KLD, ' num2str(kl_div(nlow,nhigh))])

%Beta Triggered Plots;
% 5 iterations (5*.4 = 2 sec prior) to reward :
figure()
hold on
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
    
    sem=std(ft_mat,0, 1)/sqrt(size(ft_mat,1));% standa
    mn = mean(ft_mat, 1);
    t = [.4*-5:.4:0];
    errorbar(t, mn, sem,'color',cmap{i},'LineWidth',3,'MarkerSize',30)
end
legend('Targ: -6','Targ: -2','Targ: 2','Targ:6','Location','northwest')
xlabel('Time Prior to Reward (sec)','FontSize',20)
ylabel('Beta (10-20 Hz) Power','FontSize',20)
LEGH = legend;
set(LEGH,'Location','northwest')

%Spec triggered plots:
if spec_plot==1
    
    
    figure()
    flim = 50;
    hold on
    params.Fs = 422;
    params.tapers = [3 5];
    [S, f] = mtspectrumc(zeros(168,6),params);
    t = [.4*-5:.4:0];
    mximm = [];
    mnimm = [];
    for i = 1:length(targ_locs)
        subplot(2,2,i)
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
            [Sind, f_i] = mtspectrumc(dat', params);
            spec_mat(r,:,:) = Sind';
        end
        
        mn = squeeze(mean(spec_mat, 1));
        imagesc(t, f(f<flim), log10(mn(:,f<flim))')
        mximm = [mximm max(max(log10(mn(:,f<flim))))];
        mnimm = [mnimm min(min(log10(mn(:,f<flim))))];
        title(['Targ: ' num2str(targ_locs(i))])
        xlabel('Time Before Reward (sec)')
        ylabel('Frequency (Hz)')
        if i==4
            colorbar()
        end
        
        %legend('Targ_y: -6','Targ_y: -2','Targ_y: 2','Targ_y:6')
    end
    
    for i = 1:length(targ_locs)
        subplot(2,2,i)
        set(gca, 'CLim', [max(mnimm), min(mximm)]);
    end
end
end