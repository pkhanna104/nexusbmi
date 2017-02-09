day = {'020217', '020317', '020617', '020717', '020817'};
blocks = {'jklm', 'def', 'defg', 'ghi', 'nop'};
ix_to_analyze = { {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]}, ...
                  {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  };

% day = { '020617', '020717', '020817'};
% blocks = { 'defg', 'ghi', 'nop'};
% ix_to_analyze = {{[1, -1], [1, -1], [1, -1], [1, -1]},...
%                   {[1, -1], [1, -1], [1, -1]},...
%                   {[1, -1], [1, -1], [1, -1]},...
%                   };

              
              
%Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])
trim_n_targs = 0;
rem_targ_faster_than_n_secs = 0;

% Plot time to target by day / block: 
[nf, rt] = plot_targs(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs);

% Plot distribution of spec by dat: 
low_high = [1, 3];


col_dist = [215,25,28;
253,174,97;
255,255,191;
166,217,106;
26,150,65;]/256;

for d=1:length(day)
    dayz = {day{d}};
    blockz = {blocks{d}};
    ix_to_analyzez = {ix_to_analyze{d}};
    spec_dist_gen(blockz, dayz, ix_to_analyzez, 'ix', trim_n_targs, low_high, col_dist(d, :));
end

% Plot distributions of beta | target on by day, normalized by movement
% mean and std. 

move_blocks = {'i', 'c', 'c', 'd', 'm'};
%move_blocks = { 'c', 'd', 'm'};
beta_dist_analysis(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, move_blocks)

plot_STN(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs);


