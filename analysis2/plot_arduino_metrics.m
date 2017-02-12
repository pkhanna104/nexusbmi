function plot_arduino_metrics(mets, trial_outcome)

% #1: RT
% #2: Open or Close first
% #3: Number of Taps (+/- combos)
% #4: Amp of Taps
% #5: RMS Velocity
% #6: RMS Angle
% #7: Spectral Peak
% #8: Spectral Power @ Peak

%Plot 1, 3, 5, 6, 7, 8 as boxplot
met_ixs = [1, 3, 4, 5, 6, 7, 8];
names = {'RT', '#Taps', '1st Tap Amp', 'RMS Vel', 'RMS Ang', 'Spec Pk', 'Spec Pk Pwr'};
mets_consol = cell(2, length(met_ixs));
rt_consol = cell(2, 1);
for trl = 1:size(trial_outcome, 1)
    if isfield(mets, strcat('trl_', num2str(trl)))
        targ = trial_outcome(trl, 2);
        if targ == -6
            tix = 1;
        elseif targ == 6
            tix = 2;
        end
        
        for m = 1:length(met_ixs)
            mix = met_ixs(m);
            if m == 1
                rt_consol{tix} = [rt_consol{tix}; mets.(strcat('trl_', num2str(trl))){mix}];
            elseif m == 3
                mets_consol{tix, m} = [mets_consol{tix, m},...
                    mets.(strcat('trl_', num2str(trl))){mix}(1)];
            else
                mets_consol{tix, m} = [mets_consol{tix, m},...
                    mets.(strcat('trl_', num2str(trl))){mix}];
            end
        end
    end
end

 
for m = 2:length(met_ixs)
    bot = mets_consol{1, m};
    top = mets_consol{2, m};
       
    if m == 3
        pos_bot = bot(bot > 0);
        pos_top = top(top > 0);
        P = ranksum(pos_bot, pos_top);
        fprintf('pos tap #1 amp: p = %d \n', [P])
        
        pos_bot = bot(bot < 0);
        pos_top = top(top < 0);
        P = ranksum(pos_bot, pos_top);
        fprintf('neg tap #1 amp: p = %d \n', [P])
    else
        P = ranksum(bot, top);
        bar_plot_bot_top(bot, top, names{m}, P)
    end
end

figure; 
for r = 1:1 %:size(rt_consol{1}, 2)
    %subplot(1, size(rt_consol{1}, 2), r); 
    hold on;
    bot = rt_consol{1}(:, r);
    top = rt_consol{2}(:, r);
    if r < 4
        bot = bot(and(bot > .2, bot < 1.5));
        top = top(and(top > .2, top < 1.5));
    elseif r == 4
        bot = bot(bot ~=0);
        top = top(top ~= 0); 
    end
    
    %plot(randn(length(bot), 1)*.2, bot, 'b.')
    %plot(2+ randn(length(top), 1)*.2, top, 'r.')
    P = ranksum(bot, top);
    bar_plot_bot_top(bot, top, 'Movement Onset Time (secs)', P)
    fprintf('rt %d: %d, mean bot: %d, mean top: %d \n', [r, P, median(bot), median(top)])    
end
end

function bar_plot_bot_top(bottom, tops, ylab, p)
    figure; hold all;
    h = bar(1, mean(bottom));
    set(h, 'EdgeColor', 'none')
    set(h, 'FaceColor', [46, 139, 87]/255)
    h2 = errorbar(1, mean(bottom), std(bottom)/sqrt(length(bottom)));
    set(h2, 'LineWidth', 2)
    set(h2, 'Color', [0, 0, 0]);
    
    h = bar(2, mean(tops));
    set(h, 'EdgeColor', 'none')
    set(h, 'FaceColor', [255, 0, 0]/255)
    h2 = errorbar(2, mean(tops), std(tops)/sqrt(length(tops)));
    set(h2, 'LineWidth', 2)
    set(h2, 'Color', [0, 0, 0]);
    
    ax = gca;
    set(ax, 'XTick', [1, 2])
    set(ax, 'XTickLabel', {'Bottom Beta Target', 'Top Beta Target'});
    ylabel(ylab);
    title(['Ranksum Test: p = ' num2str(p)])
end

