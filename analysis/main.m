
plot_subj1()

%Beta triggered : 
spec_plot=0;
spec_dist_subj1('cdef',[1,1,1,1],[0,0,0,0],spec_plot)
spec_dist_subj1('gh',[141,1],[0,4],spec_plot)

%Chance:
[FT, RAW, TARG, CURS, REW, idx] = concat_dat('gh', [141,1],[0,4]);
rew = calc_chance(CURS,100);
rew2 = calc_chance_2targ(CURS,100);

[n, x] =hist(rew,20);
[n2,x2] = hist(rew2);

plot(x, n/sum(n),'b-')
hold on
plot([length(REW), length(REW)], [0,.5],'b--')


rew_loc = TARG(REW);
low = find(rew_loc==-6);
hi = find(rew_loc==6);
idx2 = [low;hi];
plot(x2, n2/sum(n2), 'g-')
plot([length(idx2), length(idx2)], [0,.5],'g--')