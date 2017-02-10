function plot_STN(blocks, date, tslice, tslice_opt,...
    trim_n_targs, rem_targ_faster_than_n_secs)

% Inputs: See 'concat_dat_gen' for description / format of inputs
%Target Color Map:
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len, ~, timeout_tm] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

mins_per_epoch = 2.5;
epoch_step = round(mins_per_epoch*60/0.4);
end_ = trial_outcome(end, 1);
epoch_ix = 1:epoch_step:end_;

unique_targs = sort(unique(trial_outcome(:,2)));
perc_corr = zeros(length(unique_targs), length(epoch_ix)-1);
mean_t2t = zeros(length(unique_targs), length(epoch_ix)-1);

avg_beta_power = zeros(length(epoch_ix)-1, 2);
med_beta_power = zeros(length(epoch_ix)-1, 2);
var_beta_power = zeros(length(epoch_ix)-1, 2);

for e=1:length(epoch_ix(1:end-1))
    P1 = pxx{1}(:, epoch_ix(e):epoch_ix(e+1));
    P1(P1 == 0) = nan;
    P2 = pxx{2}(:, epoch_ix(e):epoch_ix(e+1));
    P2(P2 == 0) = nan;
    
    avg_beta_power(e, 1) = nanmean(unrav(P1));
    avg_beta_power(e, 2) = nanmean(unrav(P2));
    
    med_beta_power(e, 1) = nanmedian(unrav(P1));
    med_beta_power(e, 2) = nanmedian(unrav(P2));
    
    var_beta_power(e, 1) = nanvar(unrav(P1)-nanmean(unrav(P1)));
    var_beta_power(e, 2) = nanvar(unrav(P2)-nanmean(unrav(P2)));
    
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
            mean_t2t(t, e) = 0.4*mean(trial_outcome(time_ix(targ_ix), 4) - trial_outcome(time_ix(targ_ix), 1));
        end
    end
end

time_ax = epoch_ix*0.4/(60);

%% STN vs. Performance

% STN mean vs. Hi / Lo Beta
for i = 1:3
    switch i
        case 1
            X = avg_beta_power;
            lab = ' Avg';
        case 2
            X = med_beta_power;
            lab = ' Med';
        case 3
            X = var_beta_power;
            lab = ' Var';
    end

    figure;
    subplot(2, 3, 1)
    for tg = 1:3
        subplot(2, 3, tg)
        plot(perc_corr(tg, :), X(:, 2), '.')
        title(strcat('Targ:', num2str(unique_targs(tg))))
        ylabel(strcat('STN', lab))
        xlabel('Perc Corr')
    end

    for tg = 1:3
        subplot(2, 3, tg+3)
        plot(mean_t2t(tg, :), X(:, 2), '.')
        title(strcat('Targ:', num2str(unique_targs(tg))))
        ylabel(strcat('STN', lab))
        xlabel('Mean T2T')
    end
end
% 
figure;
ax = plot(mean(mean_t2t([1, 3], :), 1), avg_beta_power(:, 2), '.');
hold all;
p = plt_lin_reg(ax, mean(mean_t2t([1, 3], :), 1), avg_beta_power(:, 2));
title(strcat('Lin Reg. Sig. p = ', num2str(p)))
xlabel('Time to Target')
ylabel('Mean STN Beta Power')

figure;
plot(mean(mean_t2t([1, 3], :), 1), var_beta_power(:, 2), '.'); hold all;
p = plt_lin_reg(ax, mean(mean_t2t([1, 3], :), 1), var_beta_power(:, 2));
title(strcat('Lin Reg. Sig. p = ', num2str(p)))
xlabel('Time to Target')
ylabel('STN Beta Power Variance')

figure;
plot( var_beta_power(:, 2),  avg_beta_power(:, 1), '.'); hold all;
p = plt_lin_reg(ax, var_beta_power(:, 2),  avg_beta_power(:, 1));
title(strcat('Lin Reg. Sig. p = ', num2str(p)))
xlabel('STN Beta Variance')
ylabel('M1 Beta Power')

figure;
plot( var_beta_power(:, 2),  var_beta_power(:, 1), '.'); hold all;
p = plt_lin_reg(ax, var_beta_power(:, 2),  var_beta_power(:, 1));
title(strcat('Lin Reg. Sig. p = ', num2str(p)))
xlabel('STN Beta Variance')
ylabel('M1 Beta Variance')

% figure;
% plot( avg_beta_power(:, 2),  avg_beta_power(:, 1), '.'); hold all;
% p = plt_lin_reg([], avg_beta_power(:, 2),  avg_beta_power(:, 1));
% title(strcat('Lin Reg. Sig. p = ', num2str(p)))
% xlabel('STN Beta Power')
% ylabel('M1 Beta Power')
% 
% figure;
% plot( avg_beta_power(:, 2),  var_beta_power(:, 1), '.'); hold all;
% p = plt_lin_reg([], avg_beta_power(:, 2),  var_beta_power(:, 1));
% title(strcat('Lin Reg. Sig. p = ', num2str(p)))
% xlabel('STN Beta Power')
% ylabel('M1 Beta Power Variance')




%% STN vs. Motor
figure;

subplot(3, 1, 1)
plot(avg_beta_power(:, 1), avg_beta_power(:, 2), '.')
ylabel('Mean STN Beta Power')
xlabel('Mean M1 Beta Power')

subplot(3, 1, 2)
plot(avg_beta_power(:, 1), var_beta_power(:, 2), '.')
ylabel('STN Beta Power Variance')
xlabel('Mean M1 Beta Power')

subplot(3, 1, 3)
plot(var_beta_power(:, 1), var_beta_power(:, 2), '.')
ylabel('STN Beta Power Variance')
xlabel('M1 Beta Power Variance')


end

function p = plt_lin_reg(ax, X, Y)
    if size(X, 1) ~= size(Y, 1)
        X = X';
    end
    assert(all(size(X)==size(Y)))
    
    P = polyfit(X, Y, 1);
    yhat = polyval(P, X);
    plot(gca, X, yhat, 'b--');

    lm = fitlm(X, Y);
    [p,F,d] = coefTest(lm);
end
    
    

