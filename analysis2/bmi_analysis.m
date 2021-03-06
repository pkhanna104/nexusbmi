day = {'020217', '020317', '020617', '020717', '020817', '020917', ...
    '021017', '021317', '021417', '021517'};
blocks = {'jklm', 'def', 'defg', 'ghi', 'nop', 'efgh', 'cd', 'cde',...
    'cde', 'df'};
ix_to_analyze = { {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]}, ...
                  {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1]},...
                  };
% 
% day = { '020617', '020717', '020817', '020917'};
% blocks = { 'defg', 'ghi', 'nop', 'efgh'};
% ix_to_analyze = {{[1, -1], [1, -1], [1, -1], [1, -1]},...
%                   {[1, -1], [1, -1], [1, -1]},...
%                   {[1, -1], [1, -1], [1, -1]},...
%                   {[1, -1], [1, -1], [1, -1], [1, -1]},...
%                   };
% 
%               
              
%Input: trim_n_targs: any targets to trim? (format: [ 0 0 0 10])
trim_n_targs = 0;
rem_targ_faster_than_n_secs = 0;

% Plot time to target by day / block: 
[nf, rt] = plot_targs(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs);

% Plot distribution of spec by dat: 
low_high = [1, 3];

% col_dist = [158,1,66;
% 213,62,79;
% 244,109,67;
% 253,174,97;
% 254,224,139;
% 230,245,152;
% 171,221,164;
% 102,194,165;
% 50,136,189;
% 94,79,162;]/255;

col_dist = [228,26,28;
55,126,184;
77,175,74]/255;

cond = {};
cond{1} = 1:3;
cond{2} = 4:6;
cond{3} =7:10;

h=[];

for c = 1:3
    dayz = day(cond{c});
    blockz = blocks(cond{c});
    ix_to_analyzez = ix_to_analyze(cond{c});
    h(c) = spec_dist_gen(blockz, dayz, ix_to_analyzez, 'ix', trim_n_targs,...
        low_high, col_dist(c, :));
end
legend(h, 'Early', 'Med', 'Late')

% Plot distributions of beta | target on by day, normalized by movement
% mean and std. 

move_blocks = {'i', 'c', 'c', 'd', 'm', 'a', 'a', 'a', 'a', 'a'};
%move_blocks = { 'c', 'd', 'm'};
beta_dist_analysis(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, move_blocks)

% BMI 
plot_STN(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, rem_targ_faster_than_n_secs);

% Post Target Beta desynchronization

hh = [];
for c=1:3
    dayz = day(cond{c});
    blockz = blocks(cond{c});
    ix_to_analyzez = ix_to_analyze(cond{c});
    hh(c) = beta_desynch_tapping(blockz, dayz, ix_to_analyzez, 'ix', trim_n_targs, low_high, col_dist(c, :));
end
legend(hh, 'Early', 'Med', 'Late')

beta_desynch_tapping(blocks, day, ix_to_analyze, 'ix', trim_n_targs,...
    low_high, col_dist(d, :));


% Remove days / blocks/ w/p arduino files
day = {'020217', '020317', '020617', '020717', '020817', '020917',...
    '021017', '021317', '021417', '021517'};
blocks = {'jklm', 'def', 'defg', 'g', 'no', 'efgh', 'cd', 'cd', 'cd', 'd'};
ix_to_analyze = { {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1]}, ...
                  {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1]},...
                  {[1, -1], [1, -1]},...
                  {[1, -1], [1, -1], [1, -1], [1, -1]},...
                  {[1, -1], [1, -1]},...
                  {[1, -1], [1, -1]},...
                  {[1, -1], [1, -1]},...
                  {[1, -1]},...
                  };
ard_Fs = 50; % Hz
trim_n_targs = 0;

% Arduino Analysis: 
[mets, hr, lhmet, trial_outcome] = extract_arduino_tapping_mets(blocks, day, ix_to_analyze, 'ix',...
    trim_n_targs, ard_Fs);

% Arduino plotting
plot_arduino_metrics(mets, trial_outcome)

% HR plotting: 
plot_arduino_hr(hr, trial_outcome)

