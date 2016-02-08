% Plot Targets for All Patients

% Patient 1:
plot_targs('gh', '050815', {[141 -1],[1 -1]}, 'ix', 0, 0)
spec_dist_gen('gh', '050815', {[1 -1],[1 -1]}, 'ix', 0);
[rew_sim, rew_act] = chance_by_targ('gh', '050815', {[1 -1],[1 -1]}, 'ix', 0,[-6 2 6], 10e10, 1000);

% Patient 2:
plot_targs('i', '092815', {[1 -1]}, 'ix', 0, 0)
spec_dist_gen('i', '092815', {[1 -1]}, 'ix', 0);
[rew_sim, rew_act] = chance_by_targ('i', '092815', {[1 -1]}, 'ix', 0, [-6 6], 10e10, 1000);

% Patient 3:
plot_targs('df', '103015', {[1 -1], [1 -1]}, 'ix', 0)
spec_dist_gen('df', '103015', {[1 -1],[1 -1]}, 'ix', 0);

plot_targs('jk', '103015', {[1 -1], [1 -1]}, 'ix', 0)
spec_dist_gen('jk', '103015', {[1 -1],[1 -1]}, 'ix', 0);

plot_targs('dfjk', '103015', {[1 -1], [1 -1], [1 -1], [1 -1]}, 'ix', 0)
spec_dist_gen('dfjk', '103015', {[1 -1],[1 -1], [1 -1], [1 -1]}, 'ix', 0);

include_tgs = [-2 2 6 ];
[rew_sim, rew_act] = chance_by_targ('jk', '103015', {[1 -1],[1 -1]}, 'ix',...
    0, include_tgs, 60, 1000);


%timeout for patient 3
% d: 30 sec
% f: 22.5 sec? 
% j: 60 sec
% k: 60 sec


%3 patient chance plot: 
f = figure(55);
ax = gca(f);
ax1 = subplot(3,1,1); hold all;
ax2 = subplot(3,1,2); hold all;
ax3 = subplot(3,1,3); hold all;

[rew_sim, rew_act] = chance_by_targ(ax1, 'gh', '050815', {[1 -1],[1 -1]}, 'ix', 0,[-6 2 6], 10e10, 1000);
[rew_sim, rew_act] = chance_by_targ(ax2, 'i', '092815', {[1 -1]}, 'ix', 0, [-6 6], 10e10, 1000);

include_tgs = [-6 -2 2 6 ];
[rew_sim, rew_act] = chance_by_targ(ax3, 'jk', '103015', {[1 -1],[1 -1]}, 'ix',...
    0, include_tgs, 60, 1000);
