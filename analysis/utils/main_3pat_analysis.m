% Plot Targets for All Patients

% Patient 1:
plot_targs('gh', '050815', {[141 -1],[1 -1]}, 'ix', 0, 0)
spec_dist_gen('gh', '050815', {[1 -1],[1 -1]}, 'ix', 0, [1, 4]);

figure()
ax1 = subplot(1,2,1);hold on;
ax2 = subplot(1,2,2);hold on;

figure()
ax21 = subplot(1,3,1);hold on;
ax22 = subplot(1,3,2);hold on;
ax23 = subplot(1,3,3);hold on;

figure()
ax = gca;

spec_dist_early_late(ax2,ax21,'gh', '050815', {[1 -1],[1 -1]}, 'ix', 0, [1, 4], [10, 20]);
spec_dist_early_late(ax1,ax,'cdef', '050815', {[1 -1],[1 -1],[1 -1],[1 -1]}, 'ix', 0, [1, 4], [10, 20])

[rew_sim, rew_act, slope_dist] = chance_by_targ(gca, 'gh', '050815', {[141 -1],[1 -1]}, 'ix',...
    0,[-6 6], 10e10, 100, [1.75, 2]);

% Patient 2:
plot_targs('i', '092815', {[1 -1]}, 'ix', 0, 0)
spec_dist_gen('i', '092815', {[1 -1]}, 'ix', 0);
[rew_sim, rew_act] = chance_by_targ(gca, 'i', '092815', {[1 -1]}, 'ix', 0, [-6 6], 10e10, 1000, 2);


figure()
ax1 = subplot(1,2,1);hold on;
ax2 = subplot(1,2,2);hold on;

figure()
ax3 = subplot(1,2,1);hold on;
ax4 = subplot(1,2,2);hold on;
spec_dist_early_late(ax2, ax22, 'i', '092815', {[1 -1]}, 'ix', 0, [1, 4], [12.5, 17.5])
spec_dist_early_late(ax1, ax, 'gh', '092815', {[1 -1],[1 -1]}, 'ix', 0, [1, 4], [12.5, 17.5])



% Patient 3:
plot_targs('df', '103015', {[1 -1], [1 -1]}, 'ix', 0, 0)
spec_dist_gen('df', '103015', {[1 -1],[1 -1]}, 'ix', 0);

plot_targs('jk', '103015', {[1 -1], [1 -1]}, 'ix', 0, 0)
spec_dist_gen('jk', '103015', {[1 -1],[1 -1]}, 'ix', 0);

plot_targs('dfjk', '103015', {[1 -1], [1 -1], [1 -1], [1 -1]}, 'ix', 0, 0)
spec_dist_gen('dfjk', '103015', {[1 -1],[1 -1], [1 -1], [1 -1]}, 'ix', 0);

figure()
ax1 = subplot(1,2,1);hold on;
ax2 = subplot(1,2,2);hold on;

figure()
ax3 = subplot(1,2,1);hold on;
ax4 = subplot(1,2,2);hold on;


spec_dist_early_late(ax1, ax, 'd', '103015', {[1 -1],[1 -1], [1 -1], [1 -1]}, 'ix', 0, [2, 4], [20, 30]);
spec_dist_early_late(ax2, ax23, 'fjk', '103015', {[1 -1],[1 -1], [1 -1], [1 -1]}, 'ix', 0, [2, 4], [20, 30]);




include_tgs = [-2 6 ];
[rew_sim, rew_act] = chance_by_targ(gca, 'dfjk', '103015', {[1 -1],[1 -1], [1 -1], [1 -1]}, 'ix',...
    0, include_tgs, 60, 1000, 2);


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
