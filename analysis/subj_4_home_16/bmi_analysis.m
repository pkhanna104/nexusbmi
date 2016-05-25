% Plot Targets for All Patients

% Patient 1:
day = {'052016','052316', '052416'};
blocks = {'abcd', 'fgh', 'bcd'};
ix_to_analyze = {{[1, -1], [1, -1], [1, -1], [1, -1]}, ...
    {[1, -1], [1, -1], [1, -1]}, {[1, -1], [1, -1], [1, -1]}};

% day = {'052416'};
% blocks = {'bcd'};
% ix_to_analyze = {{[1, -1], [1, -1], [1, -1]}};
% 

%Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])
trim_n_targs = 0;
rem_targ_faster_than_n_secs = 0;

plot_targs(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs)

low_high = [1, 3];
spec_dist_gen(blocks, day, ix_to_analyze, 'ix', trim_n_targs, low_high);

include_targs = [ -6 6];
timeout = 45;
iterations = 100;
%assist = 15; %Only include assist if you want it in the chance_calculations!
target_sizes_by_block = [2]; %length of this must be same as length of blocks

figure()
[rew_sim, rew_act, slope_dist] = chance_by_targ(gca, blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, include_targs, timeout, iterations, target_sizes_by_block, assist);

