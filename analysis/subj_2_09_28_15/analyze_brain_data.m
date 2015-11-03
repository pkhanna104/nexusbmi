function analyze_brain_data(blocks, day)

TD = [];
FD = [];

params = struct();
params.tapers = [3 5];
params.pad = 0;
params.Fs = 422;

for b = 1:length(blocks)
    [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state, dat] = parse_dat(blocks(b), day);
    FD = [FD; raw_pxx(:,2)];
    TD = [TD; raw_td_m1];
end

[S, t, f] = mtspecgramc(TD', [.4 .4], params);
figure; subplot(2,1,1);
imagesc(0.4*(1:size(S,2)),f, log10(S))
xlabel('Time (sec)','fontsize',15)
ylabel('Frequency (Hz)','fontsize', 15)
title('Multitaper FFT','fontsize',15)

subplot(2,1,2)
plot(f, log10(mean(S,2)))
ylabel('Log PSD','fontsize',15)
xlabel('Frequency (Hz)','fontsize', 15)

[Pxx, w] = pwelch(rand(169,1), 128, 0, 128);
PXX= zeros(length(w), size(S,2));
for p=1:size(S,2)
    [pxx,W] = pwelch(TD(p,:), 128, 0, 128, 422);
    PXX(:,p) = pxx;
end
figure;subplot(2,1,1)
imagesc(.4*(1:size(S,2)), W, log10(PXX))
xlabel('Time (sec)','fontsize',15)
ylabel('Frequency (Hz)','fontsize', 15)
title('Standard FFT','fontsize',15)

subplot(2,1,2)
plot(W, log10(mean(PXX,2)))
ylabel('Log PSD','fontsize',15)
xlabel('Frequency (Hz)','fontsize', 15)

bi = find(W>=25 & W<=40);
figure;hold all;
plot(0.4*(1:size(PXX,2)), sum(PXX(bi,:),1))
plot(0.4*[1:length(FD)], FD)

figure;
plot(sum(PXX(bi,:),1), FD, '.')

