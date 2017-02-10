function f = concat_dat_gen_arduino(blocks, date, idx, tslice, tslice_opt, trim_n_targs, Fs)
% Creates a function where you enter an input (blk, dat, desired indices)
% and it returns the indices you need for the arduino

fid = fopen('config.txt','r');
tmp= {{'',''}};
while ~strcmp(tmp{1}(1),'root')
    tmp = textscan(fid, '%s', 2);
end
fclose(fid)
dir = tmp{1}{2};
slash = dir(end);

% Make a large concatenation of arduino data:
M_master = [];
T_master = [];
T_dat = [];
ard_idx = {};
for d = 1:length(date)
    ard_idx{d} = [];
end

bcnt = 1;
c_idx = cumsum(idx);

for d = 1:length(date)
    for b = 1:length(blocks{d})
        
        fname = [dir 'data2' slash 'txt' date{d} blocks{d}(b) '__ard.txt'];
        fname2 = [dir 'data2' slash 'dat' date{d} blocks{d}(b) '_.mat'];
        
        try
            M = dlmread(fname, ',', 1, 0);
            load(fname2);
            ix = size(M, 1);
            ard_idx{d} = [ard_idx{d} ix];
            
            %Resample at desired sampling rate:
            m = [];
            for i=2:size(M, 2)
                %[mi, mt] = resample(M(:, i), M(:, 1), Fs);
                mt = [M(1, 1):1/Fs:M(end, 1)]';
                mi = interp1(M(:, 1), M(:, i), mt);
                
                if i == 2
                    m = [mt];
                end
                
                m = [ m mi];
            end
            
            M_master = [M_master; m];
            
            tsl = tslice{d}{b};
            [tsl_start, tsl_stop] = get_tslice_ix(dat, tsl, tslice_opt, trim_n_targs);
            if bcnt > 1
                T_master = [T_master; T_dat(end)+m(:,1)];
                T_dat = [T_dat; T_dat(end)+dat.rawdata_abs_time(tsl_start:tsl_stop)'];
                
            elseif bcnt == 1
                T_dat = dat.rawdata_abs_time(tsl_start:tsl_stop)';
                T_master = m(:,1);
            end
            assert(length(T_dat) == c_idx(bcnt));
        catch
            ard_idx{d} = [ard_idx{d} 0];
        end
        
        bcnt = bcnt + 1;
    end
end
disp('done!')
f = @(idxx) fcn_key(idxx, ard_idx, M_master, T_master, T_dat, blocks, date, Fs, c_idx);
end

function mix = fcn_key(idx, ard_idx, M_master, T_master, T_dat, blocks, dates, fs, c_idx)

% Inputs: idx (4500:4550 --> cumulative index)
%         ard_ix, cell array of indices
%         M_master, matrix of values
%         T_master, M_master(:, 1)
%         T_dat, cumulative dat.rawdata_abs_value
%         blocks = {{'bcd'}, ...
%`        dates = {'020217', '020317', ...}

% We get the arduino indices from the block / date:

i = find(c_idx > idx(end));
i = i(1);

ard_ix_sub = [-1 0];
bcnt = 1;
for d = 1:length(dates)
    for b = 1:length(blocks{d})
        ard_ix_sub = [ard_ix_sub(end)+1:ard_ix_sub(end)+ard_idx{d}(b)];
        if bcnt == i
            AIX = ard_ix_sub;
        end
        bcnt = bcnt + 1;
    end
end

% Block and date arduino data
m = M_master(AIX, :);
t = T_master(AIX);

% Time slice from desired idx:
T_dat2 = T_dat(idx);

% Is the first index of arduino time close enough to the any ix of dat_t?

T0 = t(1);
[mn, ix_d] = min(abs(T_dat2 - T0));

if mn < .2
    %Segments close by beginning of arduino stat
    if ix_d > 1
        %Where only partially in 'arduino part'
        aft_ix = floor((length(T_dat2) - ix_d)*.4*fs);
        bef_ix = floor(ix_d*.4*fs);
        mix = zeros(aft_ix+bef_ix, size(m, 2));
        mix(1:bef_ix, :) = nan;
        mix(bef_ix:bef_ix+aft_ix, :) = m(1:aft_ix, :);
    else
        % Where all within 'arduino'
        t0 = T_dat2(1);
        [mn, ix_d] = min(abs(t - t0));
        nix = length(T_dat2)*.4*fs;
        mix = m(ix_d:ix_d+nix, :);
    end
else
    % Segments far away from arduino start
    if ix_d == 1
        % Segment far, into arduino
        t0 = T_dat2(1);
        [mn, ix_d] = min(abs(t - t0));
        nix = length(T_dat2)*.4*fs;
        try
            mix = m(ix_d:ix_d+nix, :);
        catch
            % If too close to the end: 
            mix = zeros(nix, size(m, 2));
            mix(:, :) = nan;
            nn = size(m, 1) - ix_d + 1 ; 
            mix(1:nn, :) = m(ix_d:end, :);
        end
    else
        % segments far, outside arduino
        mix = zeros(length(ix_d)*.4*fs, size(m, 2));
        mix(:, :) = nan;
    end
    
end

end