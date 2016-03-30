function summary_stats(TARG, REW, reach_time, avg, session_length)

nrew = length(REW);

% Score: 
score = 0;
targs = [-6, -2, 2, 6];

for t=1:length(targs)
    ix = find(TARG==targs(t));
    
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



%Plot tunnel:
plot(ax, [-3, -3], [-10, 10], '-','color',[131 83 47]/255,'linewidth',5)
plot(handles.window.ax, [3, 3], [-10, 10], '-','color',[131 83 47]/255,'linewidth',5)

Y = [-6, -2, 2, 6];
X = [-3, 2.5];
for y=1:length(Y)
    for x=1:length(X)
        plot(handles.window.ax, [X(x), X(x)+.5], [Y(y)-1.5, Y(y)-1.5], '-','color',[131 83 47]/255,'linewidth',5)
        plot(handles.window.ax, [X(x), X(x)+.5], [Y(y)+1.5, Y(y)+1.5], '-','color',[131 83 47]/255,'linewidth',5)
    end
    scatter(handles.window.ax, handles.window.cursor_pos(1), Y(y), ...
        0.6*handles.window.target_default_size, [192 192 192]/256, 'filled')
end


%Cursor and Target Objects

handles.window.target = scatter(handles.window.ax, handles.window.target_pos(1), ...
    handles.window.target_pos(2),handles.window.target_default_size,...
    handles.window.target_color,'filled');

handles.window.cursor = scatter(handles.window.ax, handles.window.cursor_pos(1), ...
    handles.window.cursor_pos(2),handles.window.cursor_default_size, ...
    handles.window.cursor_color, 'filled');

handles.window.tap_dot = scatter(handles.window.ax, 8, 5, 0.5*handles.window.target_default_size,...
    'k','filled');
handles.tap_off_str = ['\fontsize{18} \color{black} TAP!'];
handles.tap_on_str = ['\fontsize{18} \color{red} TAP!'];
handles.window.tap_text = text(7, 3, handles.tap_off_str,'parent', handles.window.ax);

% %Set current text for score!'
str = ['\fontsize{20} \color{white} Score:' num2str(handles.task.point_counter)];
handles.window.text = text(5,8,str,'parent',handles.window.ax);

%Mario Up / Down: 
mapped_mario = 3;

loc = [0, 0];
ht = size(handles.mario.up,1);
ht_arr = loc(1)+linspace(-.5*mapped_mario, .5*mapped_mario, ht);
wd = size(handles.mario.up,2);
wt_arr = loc(2) + linspace(-.5*mapped_mario*wd/ht, .5*mapped_mario*wd/ht, wd);
oned = 1:size(handles.mario.up,1);
handles.mario.im = image(wt_arr, ht_arr, handles.mario.up(fliplr(oned),:,:),'parent',handles.window.ax);

%grey = rgb2gray(double(handles.mario.up(fliplr(oned),:,:)));
x = handles.mario.up(fliplr(oned),:,:);
r = x(:,:,1);g=x(:,:,2);b=x(:,:,3);
y = (0.299*r) + (0.587*g) + (0.114*b);
g = y>3;
set(handles.mario.im,'alphadata',g);



