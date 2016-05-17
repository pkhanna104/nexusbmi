% Plot Targets for All Patients

% Patient 1:
day = '050815';
blocks = 'gh';
ix_to_analyze = {[1, -1], [1, -1]};

%Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])
trim_n_targs = 0;
rem_targ_faster_than_n_secs = 0;

plot_targs(blocks, day, {[126 -1],[1 -1]}, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs)

low_high = [1, 4];
spec_dist_gen(blocks, day, ix_to_analyze, 'ix', trim_n_targs, low_high);

include_targs = [-6, -2, 2, 6];
timeout = 60;
iterations = 1000;
assist = 0; %Only include assist if you want it in the chance_calculations!
target_sizes_by_block = [1.75, 2]; %lenght of this must be same as length of blocks

[rew_sim, rew_act, slope_dist] = chance_by_targ(gca, blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, include_targs, timeout, iterations, target_sizes_by_block, assist);

