function beta_dist_analysis(blocks, date, tslice, tslice_opt, trim_n_targs,...
    move_blocks)

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, pxx, time2rew, TAPPING_IX,...
    task, trial_outcome, targ_len] = concat_dat_gen(blocks, date, tslice,...
    tslice_opt, trim_n_targs);

% Get mean and std of each beta move date:

fid = fopen('config.txt','r');
tmp= {{'',''}};
while ~strcmp(tmp{1}(1),'root')
    tmp = textscan(fid, '%s', 2);
end
fclose(fid)
dir = tmp{1}{2};
slash = dir(end);

move_data = struct();
figure;
for d = 1:length(date)
    alpha = move_blocks{d};
    fname2 = [dir 'data2' slash 'h5_' date{d} alpha '_.h5'];
    ch4 = h5read(fname2, '/neural/pxx_ch4');
    ch4(ch4 == -1) = nan;
    ch4(ch4 == 0) = nan;
    
    ch2 = h5read(fname2, '/neural/pxx_ch2');
    ch2(ch2 == -1) = nan;
    ch2(ch2 == 0) = nan;
    
    move_data.(strcat('d', date{d})).mean = nanmedian(reshape(ch4, [length(ch4)*2, 1]));
    move_data.(strcat('d', date{d})).std = nanstd(reshape(ch4, [length(ch4)*2, 1]));
    
    move_data.(strcat('d', date{d})).mean2 = nanmedian(reshape(ch2, [length(ch2)*2, 1]));
    move_data.(strcat('d', date{d})).std2 = nanstd(reshape(ch2, [length(ch2)*2, 1]));
    
    [h, i] = hist(mean(ch4,1), 20);
    subplot(2,2,1)
    plot(i, h/sum(h)); hold all;
    subplot(2, 2, 2)
    plot(ch4);
    hold all;
    
    [h, i] = hist(mean(ch2, 1), 20);
    subplot(2,2,3)
    plot(i, h/sum(h)); hold all;
    subplot(2, 2, 4)
    plot(ch2);
    hold all;
end

%Now figure out distribution of data during beta high vs. low vs.
%center vs. tapping

c_idx = cumsum(idx);
bl_len =[];
for d = 1:length(date)
    bl_len(d) = length(blocks{d});
end
c_idx_day_start = cumsum(bl_len);

bpxx = [0;0];
cix = zeros(length(date), 2);
blix = zeros(length(c_idx), 2);
bcnt = 1;
for d = 1:length(date)
    if d == 1
        cix0 = 1;
    else
        cix0 = c_idx(c_idx_day_start(d-1))+1;
    end
    cix1 = c_idx(c_idx_day_start(d));
    cix(d, :) = [cix0, cix1];
    
    for b = 1:length(blocks{d})
        if bcnt == 1;
            b0 = 1;
        else
            b0 = c_idx(bcnt-1)+1;
        end
        b1 = c_idx(bcnt);
        blix(bcnt, :) = [b0, b1];
        bcnt = bcnt + 1;
    end
    
    beta_pxx = pxx{1}(:, cix0:cix1);
    beta_pxx(beta_pxx==0) = nan;
    beta_pxx = (beta_pxx -  move_data.(strcat('d', date{d})).mean);%/ move_data.(strcat('d', date{d})).std;
    bpxx  =[bpxx beta_pxx];
end
bpxx = bpxx(:, 2:end);
db = struct();
bcnt = 1;
for d = 1:length(date)
    for b=1:length(blocks{d})
        db.(strcat('d', num2str(bcnt))).low_beta = [];
        db.(strcat('d',  num2str(bcnt))).high_beta = [];
        db.(strcat('d', num2str(bcnt))).mid_beta = [];
        db.(strcat('d',  num2str(bcnt))).tapping_beta = [];
        bcnt = bcnt + 1;
    end
end

figure;

for trl = 1:size(trial_outcome, 1)
    tg_st = max([trial_outcome(trl, 4) - floor( 5/.4), trial_outcome(trl, 1)]);
    tg_end = trial_outcome(trl, 4);
    tp_end = trial_outcome(trl, 5);
    
    d = find(and(blix(:, 1) < tg_st, blix(:, 2) > tg_end));
    if length(d) == 1
        if and(tg_end < cix(end, end), tp_end < cix(end, end))
            if trial_outcome(trl, 2) == -6
                db.(strcat('d', num2str(d))).low_beta = [db.(strcat('d', num2str(d))).low_beta bpxx(:, tg_st:tg_end)];
                db.(strcat('d', num2str(d))).tapping_beta = [db.(strcat('d', num2str(d))).tapping_beta bpxx(:, tg_end:tp_end)];
            elseif trial_outcome(trl, 2) == 6
                db.(strcat('d', num2str(d))).high_beta = [db.(strcat('d', num2str(d))).high_beta bpxx(:, tg_st:tg_end)];
                db.(strcat('d', num2str(d))).tapping_beta = [db.(strcat('d', num2str(d))).tapping_beta bpxx(:, tg_end:tp_end)];
            elseif trial_outcome(trl, 2) == 0;
                db.(strcat('d', num2str(d))).mid_beta = [db.(strcat('d', num2str(d))).mid_beta bpxx(:, tg_st:tg_end)];
            end
        end
    end
end

figure(1);
figure(2);
bins = -150:20:250;
median_d = zeros(bcnt, 1);

L = [];
H = [];
T = [];

dcnt = 1;
for d = 1:bcnt-1
    hold all
    L = [L; unrav(db.(strcat('d', num2str(d))).low_beta)];
    H = [H; unrav(db.(strcat('d', num2str(d))).high_beta)];
    T = [T; unrav(db.(strcat('d', num2str(d))).tapping_beta)];

    if ~isempty(find(c_idx_day_start==d))
        figure(1);
        subplot(length(date), 1, dcnt)
        [h_l, i] = hist(L, bins);
        medl = nanmedian(L);
        
        [h_h, i] = hist(H, bins);
        medh = nanmedian(H);
        [h_t, i] = hist(T, bins);
        
        tm1 = plot(bins, h_l/sum(h_l)); hold all;
        plot([medl, medl], [0, .3], 'color', get(tm1, 'Color'));
        
        tm = plot(bins, h_h/sum(h_h));
        plot([medh, medh], [0, .3], 'color', get(tm, 'Color'))
        
        xlim([-200, 300])
        ylim([0, .3])
        
        L = [];
        H = [];
        T = [];
        figure(2); hold all;
        plot([d+.5, d+.5], [-100, 100], 'k--')
        dcnt = dcnt + 1;
    end
    
    medl = nanmedian(unrav(db.(strcat('d', num2str(d))).low_beta));
    medh = nanmedian(unrav(db.(strcat('d', num2str(d))).high_beta));    
    median_d(d) = medh - medl;
    
    
end

figure(2); plot(median_d(1:end-1), '.');
lm = fitlm(1:bcnt-1,median_d(1:end-1)','linear');
P = polyfit(1:bcnt-1, median_d(1:end-1)', 1);
plot(1:bcnt-1, polyval(P, 1:bcnt-1), 'b-')

% [h, i] = hist(db.(strcat('d', date{d})).tapping_beta, bins);
% plot(i, h/sum(h))
% 
% [h, i] = hist(db.(strcat('d', date{d})).mid_beta, bins);
% plot(i, h/sum(h))


end

function Y = unrav(X)
% X is a 2 x n vector;
Y = reshape(X, [prod(size(X)), 1]);
end
