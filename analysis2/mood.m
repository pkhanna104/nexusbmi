%%
before = [50 60	10	30;
40	70	20	50;
40	40	30	40;
30	40	0	30;
30	50	10	50;
40	50	10	40;
30	50	10	50;
20	50	10	50;
40	60	20	60;
10	60	20	60];

after = [40	60	10	50;
40	60	30	60;
30	50	10	60;
30	50	10	40;
10	40	10	40;
10	60	10	60;
30	40	0	40;
10	60	10	50;
20	50	10	30;
10	60	10	50];

labels = {'Sad', 'Happy', 'Anxious', 'Motivated'};
%% Bar plots: 
figure; hold all;
for l = 1:length(labels)
    plot(l, mean(before(:, l)), 'b.', 'markersize', 40)
    plot(l+(0.05*randn(length(before(:, l)), 1)), before(:, l), 'b.')
    plot(l+.4, mean(after(:, l)), 'r.', 'markersize', 40)
    plot(l+.4+(0.05*randn(length(after(:, l)), 1)), after(:, l), 'r.') 
    p = ranksum(before(:, l), after(:, l));
    text(l-.2, 5, strcat('p=', num2str(p)))
end

set(gca, 'xtick', .2+[1:4])
set(gca, 'xticklabel', labels)


        

