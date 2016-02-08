function [FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, PXX_CHAN] = concat_dat_gen(blocks, date, tslice, tslice_opt, trim_n_targs)

% Method to concatenate relevant features
% Inputs: blocks, (format: 'abcdef')
% Inputs: date, (format: '050815'
% Inputs: tslice: in seconds time slice (format: {[0 -1], [0 -1], [0 600]})
%   where -1 means 'go all the way to the end'
% Inputs: tslice_opt is either 'sec' or 'targ_num' or 'ix' for units of
% tslice
% Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])

dir = 'C:\Users\Preeya\Documents\GitHub\nexusbmi\';

FT = [];
RAW_stn = [];
RAW_m1 = [];

TARG = [];
CURS = [];
REW = [];

PXX_CHAN = [];
idx = [];
ind_offs = 0;

%Stack data:
for ai = 1:length(blocks)
    
    %Load data:
    alpha = blocks(ai);
    fname = [dir 'data\dat' date alpha '_.mat'];
    load(fname)
    
    %Get tslice in indices:
    tsl = tslice{ai};
    [tsl_start, tsl_stop] = get_tslice_ix(dat, tsl, tslice_opt, trim_n_targs);
    
    %Add to arrays:
    s_ft = sum(dat.features,1);
    
    n_features = length(find(s_ft>0));
    
    FT = [FT; dat.features(tsl_start:tsl_stop,1:n_features)];
    RAW_stn = [RAW_stn; dat.rawdata_timeseries_stn(tsl_start:tsl_stop,:)];
    RAW_m1 = [RAW_m1; dat.rawdata_timeseries_m1(tsl_start:tsl_stop,:)];
    
    if isfield(dat,'target')
        targ_locs = dat.target;
        rew_inds = dat.reward_times{1};
    else
        [targ_locs, rew_inds] = get_targ_loc(dat);
    end
    
    TARG = [TARG; targ_locs(tsl_start:tsl_stop)];
    CURS = [CURS; dat.cursor(tsl_start:tsl_stop)];
    
    rews = rew_inds(rew_inds>=tsl_start & rew_inds<= tsl_stop);
    blk_rews = rews-tsl_start+ind_offs';
    REW = [REW blk_rews];
    
    if isfield(dat, 'rawdata_power_ch4')
        px_chan = cell2mat(dat.rawdata_power_ch4);
    else
        px_chan = [];
    end
    
    if ~isempty(px_chan)
        for pxi = tsl_start:tsl_stop
            pxi_cell = dat.rawdata_power_ch4{pxi};
            if ~isempty(pxi_cell)
                PXX_CHAN = [PXX_CHAN pxi_cell];
            else
                PXX_CHAN = [PXX_CHAN [0;0]];
            end
        end
    end
    ind_offs = ind_offs+(tsl_stop - tsl_start)+1;
    idx = [idx (tsl_stop - tsl_start)];
    
end

if size(FT, 2) < 3
    disp('x')
end