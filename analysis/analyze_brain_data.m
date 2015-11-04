function analyze_brain_data(blk, days)

colors = {[228, 26, 28], [55, 126, 184],[77, 175, 74], [152, 78, 163]};
labs = {'P1, Stim Off', 'P2, Stim On 130 Hz','P2, Stim Off', 'P3, Stim On 160 Hz'};
for d = 1:length(days)
    blocks = blk{d};
    TD = [];
    FD = [];

    params = struct();
    params.tapers = [3 5];
    params.pad = 0;
    params.Fs = 422;
    %labs{d} = strcat(num2str(days{d}), blocks);
    for b = 1:length(blocks)
        [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state,ix_boundaries] = parse_dat(blocks(b), days{d},[]);
        %FD = [FD; raw_pxx(:,2)];
        if sum(sum(raw_td_m1))==0
            TD = [TD; raw_td_stn];
        else
            TD = [TD; raw_td_m1];
        end
    end

    [S, t, f] = mtspecgramc(TD', [.4 .4], params);
    
    fg = figure(11);
    mnn = (mean(S,2));
    sem = (std(S,0,2)/sqrt(size(S,2)));
    plt_mn_sem(f, fg, mnn, sem);
  
    
    [Pxx, w] = pwelch(rand(169,1), 128, 0, 128, params.Fs);
    PXX = zeros(length(w), size(S,2));
    for p=1:size(S,2)
        [pxx,W] = pwelch(TD(p,:), 128, 0, 128, 422);
        PXX(:,p) = pxx;
    end
    
    fg = figure(12);
    mnn = (mean(PXX, 2));
    sem = (std(PXX, 0, 2)/sqrt(size(PXX, 2)));
    plt_mn_sem(w', fg, mnn, sem);
end

figure(12)
legend(labs)

function plt_mn_sem(freq, fg, m, sem)
    axtm = gca(fg);
    plot(axtm, freq, log10(m),'color',colors{d}/256,'linewidth',2);
    hold on;
    %p = fill([freq fliplr(freq)], log10([m-sem; fliplr(m+sem)]), colors(d));
    %set(p,'FaceAlpha',.3)
    %set(p,'EdgeAlpha',0)
end
end  
% 
% figure; subplot(2,1,1);
% imagesc(0.4*(1:size(S,2)),f, log10(S))
% xlabel('Time (sec)','fontsize',15)
% ylabel('Frequency (Hz)','fontsize', 15)
% title('Multitaper FFT','fontsize',15)
% 
% subplot(2,1,2)
% plot(f, log10(mean(S,2)))
% ylabel('Log PSD','fontsize',15)
% xlabel('Frequency (Hz)','fontsize', 15)
% 
% [Pxx, w] = pwelch(rand(169,1), 128, 0, 128);
% PXX= zeros(length(w), size(S,2));
% for p=1:size(S,2)
%     [pxx,W] = pwelch(TD(p,:), 128, 0, 128, 422);
%     PXX(:,p) = pxx;
% end
% figure;subplot(2,1,1)
% imagesc(.4*(1:size(S,2)), W, log10(PXX))
% xlabel('Time (sec)','fontsize',15)
% ylabel('Frequency (Hz)','fontsize', 15)
% title('Standard FFT','fontsize',15)
% 
% subplot(2,1,2)
% plot(W, log10(mean(PXX,2)))
% ylabel('Log PSD','fontsize',15)
% xlabel('Frequency (Hz)','fontsize', 15)
% 
% bi = find(W>=25 & W<=40);
% figure;hold all;
% plot(0.4*(1:size(PXX,2)), sum(PXX(bi,:),1))
% plot(0.4*[1:length(FD)], FD)
% 
% figure;
% plot(sum(PXX(bi,:),1), FD, '.')
% end
% end
