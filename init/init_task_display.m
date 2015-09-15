function handles = init_task_display(handles)

handles.window.task_display = figure();
set(handles.window.task_display,'Position',[10 10 860 640]);
handles.window.cursor_pos = [0, 0];
handles.window.target_pos = [0, 6];
handles.window.cursor_color = [0 1 1];
handles.window.target_color = [0 153 0]/256;

%Check if target / cursor are set
if ~isfield(handles.window,'target_radius')
    fprintf('WARNING: no target radius')
end

if ~isfield(handles.window,'cursor_radius')
    fprintf('WARNING: no cursor radius')
end

% Init Display
handles.window.ax = gca(handles.window.task_display); 
hold(handles.window.ax, 'on')

%Obtain the axes size (in axpos) in Points
currentunits = get(handles.window.ax,'Units');
set(handles.window.ax, 'Units', 'Points');
handles.window.axpos = get(handles.window.ax,'Position');
set(handles.window.ax, 'Units', currentunits);

% Setup task display: 10 x 10 
handles.window.ax = blit_display(handles.window.ax);

axpos = handles.window.axpos;
xlim = get(handles.window.ax,'XLim');

handles.window.target_default_size = inch2disp(xlim, axpos, handles.window.target_radius);
handles.window.cursor_default_size = inch2disp(xlim, axpos, handles.window.cursor_radius);

%Plot tunnel:
plot(handles.window.ax, [-3, -3], [-10, 10], '-','color',[131 83 47]/255,'linewidth',5)
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
