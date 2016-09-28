t_ax = dat.arduino.t;
acc = dat.arduino.acc(1:length(t_ax),:);

%% First upsample the acceleration data
Fs_desired = 50;
t_ideal = linspace(t_ax(1), t_ax(end), (t_ax(end)-t_ax(1))*Fs_desired);
Acc_int = interp1(t_ax, acc, t_ideal, 'spline');

%% Do PCA on 1 sec windows: 
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED, MU] = pca(Acc_int, 'Algorithm','eig');
demean_acc = (Acc_int - repmat(MU, [size(Acc_int,1),1]));
transformed = demean_acc*COEFF;

%% Use norm: 
norm_acc = sum(demean_acc.^2, 2);
plot(t_ideal, norm_acc);
hold on;
rew_t = dat.abs_time(dat.reward_times{1});
plot(rew_t, 500+ones(length(rew_t),1),'r.')

plot(dat.abs_time(outcomez(:,1)+targ_lenz'-ind_offs), 600+ones(length(targ_lenz),1),'k.')

%Plot individual traj: 
ix_tmp = find(outcomez(:,3)==9);
sub_ix = find(abs(outcomez(ix_tmp,2))>0);
ix = ix_tmp(sub_ix);

figure();
hold all;

t_snippet = linspace(0, 10, 10*Fs_desired);
for i = 1:length(ix)
    %In dat indices: 
    trial_start = dat.abs_time(outcomez(ix(i),1)-ind_offs)+targ_lenz(ix(i));
    
    %Now find index in t_ideal file: 
    [~, min_i] = min(abs(t_ideal - trial_start));
    
    %Plot first min: 
    yy = norm_acc(min_i:min_i+length(t_snippet)-1);
    j = plot(t_snippet, yy);
    hold on
    [~, bkl_i] = min(abs(t_snippet - bool_rt_blk(ix(i))));
    plot(t_snippet(bkl_i), yy(bkl_i), '.', 'color', get(j, 'Color'))
    hold off
    pause(2)
end