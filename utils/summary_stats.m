function summary_stats(TARG, REW, reach_time, avg, session_length)

nrew = length(REW);

% Score:
score = 0;
targs = [-6, -2, 2, 6];

for t=1:length(targs)
    ix = find(TARG(REW)==targs(t));
    
    if ~isempty(ix)
        % +1 for middle targets
        if abs(targs(t)) < 3
            score = score + length(ix);
            
            
        else
            for i=1:length(ix)
                if reach_time(ix(i)) < 2
                    score = score + 5;
                elseif reach_time(ix(i)) < 5
                    score = score + 3;
                elseif reach_time(ix(i)) < 10
                    score = score + 2;
                else
                    score = score + 1;
                end
            end
        end
    end
end
%Make Figure:
stats = figure();
set(stats,'Position',[10 10 860 640]);

% Init Display
ax = gca(stats);
hold(ax, 'on')

%Obtain the axes size (in axpos) in Points
% currentunits = get(handles.window.ax,'Units');
% set(handles.window.ax, 'Units', 'Points');
% handles.window.axpos = get(handles.window.ax,'Position');
% set(handles.window.ax, 'Units', currentunits);

% Setup task display: 10 x 10
ax = blit_display(ax);

% Title:
title_str = ['\fontsize{36} \color{white} Summary of Training Session:'];
stats.text = text(-8, 8, title_str, 'parent', ax);

% Stats:
time_str = ['\fontsize{24} \color{white} Length of Session: ' num2str(session_length) ' seconds'];
text(-6, 5, time_str, 'parent', ax);

nrew_str = ['\fontsize{24} \color{white} Number of Targets: ' num2str(length(REW))];
text(-4, 2, nrew_str, 'parent', ax);

score_str = ['\fontsize{24} \color{white} Total Session Score: ' num2str(score) ' points'];
text(-5.5, -1, score_str, 'parent', ax);

avg_title_str = ['\fontsize{24} \color{white} Average Target Times: '];
text(-4, -4, avg_title_str, 'parent', ax);

% Target stats:
targ_name = {'      Low', 'Mid-Low', 'Mid-High', 'High'};
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

for i = 1:length(avg)
    targ_str = ['\fontsize{20} ' targ_name{i} ' Target: '];
    text(-10+((i-1)*5), -7, targ_str, 'Color', cmap{i}, 'parent', ax);
    targ_str2 = ['\fontsize{20} ' num2str(avg(i)) ' sec'];
    text(-8+((i-1)*4.65), -9, targ_str2, 'Color', cmap{i}, 'parent', ax);
end

