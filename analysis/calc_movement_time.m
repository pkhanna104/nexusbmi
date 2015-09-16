%Get times, and target onsets; 
block = 'd';
day = '091615';

%Find data path:
[label paths] = textread('config.txt', '%s %s',5);
if strcmp(label{4},'dat')
    dir = paths{4};
end

for ai = 1:length(blocks)
    alpha = blocks(ai);
    dat_fname = ['dat' day alpha '_.mat'];
    load(dat_fname)
    iter_cnt = dat.iter_cnt;
    ft = dat.features(1:iter_cnt,3);
    
function [FT, RAW, TARG, CURS, REW, idx] = concat_dat(blocks, start_ind, rm_targs)

dir = 'C:\Users\George\Downloads\UCSF_minibmi5\';
dir2 = '/Users/preeyakhanna/Dropbox/Carmena_Lab/UCSF_minibmi5/';

%blocks = 'gh';
%start_ind = [141, 1];

FT = [];
RAW = [];
TARG = [];
CURS = [];
REW = [];
idx = [];
ind_offs = 0;

%Stack data: 
for ai = 1:length(blocks)
    alpha = blocks(ai);
    fname1 = [dir 'data\dat050815' alpha '_.mat'];
    fname2 = [dir2 'data/dat050815' alpha' '_.mat'];
    load(fname1)

    ft = dat.features(:,3);
    ix_zer = find(ft==0);
   
    act_curs = dat.cursor(ix_zer);
    c1 = dat.cursor(ix_zer-1);
    c2 = (2*act_curs) - c1;

    ft_interp = (c2*25)+300;
    ft(ix_zer) = ft_interp;

    FT = [FT; ft(start_ind(ai):end)];
    RAW = [RAW; dat.rawdata_timeseries_stn(start_ind(ai):end,:)];

    [targ_locs, rew_inds] = get_targ_loc(dat);
    TARG = [TARG; targ_locs(start_ind(ai):end)];
    CURS = [CURS; dat.cursor(start_ind(ai):end)];
    
    rews = rew_inds(rew_inds>start_ind(ai));
    blk_rews = rews-start_ind(ai)+1+ind_offs';
    blk_rews = blk_rews(1:end-rm_targs(ai));
    REW = [REW blk_rews];
    
    ind_offs = ind_offs+length(ft(start_ind(ai):end));
    
    idx = [idx length(FT)];
    
end