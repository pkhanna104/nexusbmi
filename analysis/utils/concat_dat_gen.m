function [FT, RAW_stn, RAW_m1, TARG, CURS, REW, idx, PXX_CHAN,...
    time2rew, TAPPING_IX, task, trial_outcome, targ_len] = concat_dat_gen(blocks, dates, tslice,...
    tslice_opt, trim_n_targs)

% Method to concatenate relevant features
% Inputs: blocks, (format: 'abcdef')
% Inputs: dates, (format: {'050815', '050915'};
% Inputs: tslice: in seconds time slice (format: {[0 -1], [0 -1], [0 600]})
%   where -1 means 'go all the way to the end'
% Inputs: tslice_opt is either 'sec' or 'targ_num' or 'ix' for units of
% tslice
% Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])

fid = fopen('config.txt','r');
tmp= {{'',''}};
while ~strcmp(tmp{1}(1),'root')
    tmp = textscan(fid, '%s', 2);
end
fclose(fid)
dir = tmp{1}{2};

slash = dir(end);

FT = [];
RAW_stn = [];
RAW_m1 = [];
TAPPING_IX = [];
TARG = [];
CURS = [];
REW = [];
time2rew = [];

trial_outcome = [];
targ_len = [];

PXX_CHAN = [];
idx = [];
ind_offs = 0;

%Check if dates are in cell format: {'050815', '050815'} or string format:
%'050815'

if and(length(dates)==6, ~iscell(dates(1)))
    dates = {dates};
    tslice = {tslice};
    blocks = {blocks};
    
elseif length(dates{1})==6
    %nothing happens.
else
    msgID = 'Dates in wrong format';
    msg = 'Dates must be either a single string or a cell array with string entries';
    baseException = MException(msgID,msg);
    throw(baseException)
end
%Stack data:
for di = 1:length(dates)
    date = dates{di};
    
    for ai = 1:length(blocks{di})
        
        %Load data:
        alpha = blocks{di}(ai);
        fname = [dir 'data' slash 'dat' date alpha '_.mat'];
        load(fname)
        
        %Get tslice in indices:
        tsl = tslice{di}{ai};
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
            rew_times = get_rew_timez(dat, rew_inds);
        else
            [targ_locs, rew_inds] = get_targ_loc(dat);
            rew_times = get_rew_timez(dat, rew_inds);
        end
        
        %%% GET TASK NAME %%%
        states = dat.state;
        tap_search = 1;
        cnt = 1;
        while tap_search
            if strcmp(states{cnt},'tapping')
                tap_search=0;
                task='target_tapping';
            else
                cnt = cnt + 1;
            end
            
            if cnt > length(states)
                tap_search = 0;
                task = 'target_task';
            end
        end
        
        tapping_start_offset = zeros(length(rew_inds),2);
        if strcmp(task, 'target_tapping')
            for i=1:length(rew_inds)
                
                offs = 1;
                while strcmp(states{rew_inds(i)-offs},'tapping')
                    offs = offs +1;
                end
                tapping_start_offset(i, 1) = offs-1;
                
                offs = 1;
                while and(~strcmp(states{rew_inds(i)+offs},'target'), rew_inds(i)+offs < length(states))
                    offs = offs +1;
                end
                tapping_start_offset(i, 2) = offs-1;
            end
        end
        
        
        %Find first 'tapping' before rewards:
        
        
        TARG = [TARG; targ_locs(tsl_start:tsl_stop)];
        CURS = [CURS; dat.cursor(tsl_start:tsl_stop)];
        
        rews = rew_inds(rew_inds>=tsl_start & rew_inds<= tsl_stop);
        blk_rews = rews-tsl_start+ind_offs';
        
        REW = [REW blk_rews];
        [outcomez, targ_lenz] = get_trial_outcome(dat, ind_offs);
        trial_outcome = [trial_outcome; outcomez];
        
        % TODO FIX 
        if length(find(outcomez(:,3)==9)) == length(blk_rews)
        else
        end
        
        targ_len = [targ_len, targ_lenz];
        
        taps = tapping_start_offset(rew_inds>=tsl_start & rew_inds<= tsl_stop,:);
        TAPPING_IX = [ TAPPING_IX; taps];
        
        time2rew = [time2rew rew_times(rew_inds>=tsl_start & rew_inds<= tsl_stop)];
        
        if isfield(dat, 'rawdata_power_ch4')
            [~, px_chan] = rect_cell2mat(dat.rawdata_power_ch4, [2, 1]);
        else
            px_chan = [];
        end
        
        if ~isempty(px_chan)
            for pxi = tsl_start:tsl_stop
                pxi_cell = dat.rawdata_power_ch4{pxi};
                if and(~isempty(pxi_cell), ~isnan(pxi_cell))
                    PXX_CHAN = [PXX_CHAN pxi_cell];
                else
                    PXX_CHAN = [PXX_CHAN [0;0]];
                end
            end
        end
        ind_offs = ind_offs+(tsl_stop - tsl_start)+1;
        idx = [idx (tsl_stop - tsl_start)];
        
    end
end

if size(FT, 2) < 3
    disp('x')
end
end

function time2rew2 = get_rew_timez(dat, rew_times)
time2rew2 = [];
state = dat.state;
for iii=1:length(rew_times)
    r = rew_times(iii);
    j=r;
    dt = 0;
    while (j-dt)>0 && ~strcmp(state{j - dt}, 'wait')
        dt = dt + 1;
        
    end
    time2rew2 = [time2rew2 dt];
end
end