function [rew_sim, rew_act, slope_dist] = chance_by_targ(ax, blocks, date, tslice, tslice_opt,...
    trim_n_targs, include_targs, timeout, sim_cnt, target_sizes)

[FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, px, time2targ_act] = concat_dat_gen(blocks, date,...
    tslice, tslice_opt, trim_n_targs);

if length(target_sizes) > 1
    szs = zeros(length(CURS), 1);
    start_ix = 1;
    for i =1:length(idx)
        szs(start_ix:start_ix+idx(i))=target_sizes(i);
        start_ix = idx(i)+1;
    end
else
    szs = repmat(target_sizes, [length(CURS),1]);
end
            
rew_by_targ = zeros(1,4);
tg = [-6 -2 2 6];

for ir = 1:length(REW)
    rew_i = REW(ir);
    tg_i = TARG(rew_i); %Target value when reward on
    
    ix = find(tg==tg_i);
    rew_by_targ(ix) = rew_by_targ(ix)+1;
end

[rew, rew_cnt, rew_time, time2targ] = calc_chance(CURS, sim_cnt, timeout, szs);

slope_dist = {[], [], [], []};

for i=1:sim_cnt
    for j=2:4
        b = [rew_time{i,j}' ones(length(rew_time{i,j}),1)]\time2targ{i,j}'; 
        slope_dist{j} = [slope_dist{j} b(1)];
    end
end

actual_slope = [];
rew_targ = TARG(REW);
tg = [-6 -2 2 6];
for t=1:4
    ix = find(rew_targ==tg(t));
    b = [REW(ix)' ones(length(ix),1)]\time2targ_act(ix)';
    actual_slope = [actual_slope b(1)];
end

include_ix = [];
for i=1:length(include_targs)
    ii = find(tg==include_targs(i));
    include_ix = [include_ix ii];
end

rew_sim = sum(rew_cnt(:, include_ix), 2);
rew_act = sum(rew_by_targ(include_ix));

[n, x] = hist(rew_sim, 15); 
cdf = cumsum(n)/sum(n);
plot(ax, x, cdf, 'linewidth', 3);hold on

ix = find(x>=rew_act);
if ~isempty(ix)
    p = 1 - cdf(ix(1));
else
    p = 0.0;
end

plot(ax,[rew_act, rew_act], [0,1], 'r-', 'linewidth', 3)
ylim(ax, [0 1.0])
xlabel(ax, 'Rewards in Block')
ylabel(ax, 'Simulation Cum. Dist')
title(ax, strcat('Bootstrap CDF for Targets: ', mat_to_str(include_ix), ': p = ', num2str(p)))

end


function str = mat_to_str(mat)
    str = '';
    for zz=1:length(mat)
        m = num2str(mat(zz));
        str = strcat(str, m, ', ');
    end
end