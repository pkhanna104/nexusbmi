function analyze_brain_data(blk, days)
% analyze_brain_data({['h'],['a'],['jk']}, {'050815','092815','103015'})
% analyze_brain_data({['h'],['i'],['jk']}, {'050815','092815','103015'})

colors = {[228, 26, 28], [55, 126, 184],[77, 175, 74]};
labs = {'P1, Stim Off', 'P2, Stim On 130 Hz', 'P3, Stim On 160 Hz'}; 
for d = 1:length(days)
    blocks = blk{d};
    TD = [];
    FD = [];

    params = struct();
    params.tapers = [3 5];
    params.pad = 3;
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
  
    beta_f = find(f<=20 & f >=10); 
    beta = sum(S(beta_f, :), 1);
    disp(strcat('var beta MTM: ', num2str(std(beta)), days{d}))
       
    
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

    beta_f = find(w<=20 & w>=10); 
    beta = sum(PXX(beta_f, :), 1);
    disp(strcat('var beta Welch: ', num2str(std(beta)), days{d})) 
    
end

figure(12)
legend(labs)
box off
xlim([5, 170])
xlabel('Frequency (Hz)')
ylabel('Log_{10} Power')

figure(11)
legend(labs)
box off
xlim([5, 170])
xlabel('Frequency (Hz)')
ylabel('Log_{10} Power: MTM Method')

function plt_mn_sem(freq, fg, m, sem)
    axtm = gca(fg);
    plot(axtm, freq, log10(m),'color',colors{d}/256,'linewidth',2);
    hold on;
%     p = fill([freq fliplr(freq)], log10([m-sem; flipud(m+sem)]), colors{d}/256);
%     set(p,'FaceAlpha',.5)
%     set(p,'EdgeAlpha',0)
end
end  