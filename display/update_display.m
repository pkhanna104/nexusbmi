function handles = update_display(handles)

%Update y pos of cursor / target
%Cursor and Target Objects
% handles.window.cursor = plot(handles.window.ax, handles.window.cursor_pos(1), handles.window.cursor_pos(2),'o',...
%     'MarkerSize', handles.window.cursor_radius,'MarkerFaceColor',handles.window.cursor_color,...
%     'MarkerEdgeColor', handles.window.cursor_color);
% 
% handles.window.target = plot(handles.window.ax, handles.window.target_pos(1), handles.window.target_pos(2),'o',...
%     'MarkerSize', handles.window.target_radius,'MarkerFaceColor',handles.window.target_color, ...
%     'MarkerEdgeColor', handles.window.target_color);


set(handles.window.cursor, 'ydata', handles.window.cursor_pos(2));
set(handles.window.target, 'ydata', handles.window.target_pos(2));

if strcmp(handles.task.state, 'reward')
    set(handles.window.target, 'MarkerFaceColor', 'y');
    set(handles.window.target, 'SizeData', handles.window.target_default_size*1.3);

    %Set cursor to black and move it to the side
    set(handles.window.cursor, 'MarkerFaceColor', 'k');
    set(handles.window.cursor, 'xdata', -5);

    str = ['\fontsize{20} \color{white} Score:' num2str(handles.task.point_counter)];
    set(handles.window.text,'string',str);

elseif strcmp(handles.task.state, 'wait')
    set(handles.window.target, 'MarkerFaceColor', handles.window.target_color);
    set(handles.window.cursor, 'MarkerFaceColor', 'c');
    set(handles.window.cursor, 'xdata', 0);
    set(handles.window.target, 'SizeData', handles.window.target_default_size);
    
end

if ~isnan(handles.task.tap_bool)
    if handles.task.tap_bool
        set(handles.window.tap_dot, 'MarkerFaceColor', 'r');
    else
        set(handles.window.tap_dot, 'MarkerFaceColor', 'k')
    end
end

try
    if ~isnan(handles.task.rtap_bool)
        if handles.task.rtap_bool
            set(handles.window.tap_dot2, 'MarkerFaceColor', 'r');
        else
            set(handles.window.tap_dot2, 'MarkerFaceColor', 'k');
        end
    end
catch
    tmp=nan;
end

blit_display(handles.window.ax);

handles = plot_mario([handles.window.cursor_pos(2), 0],handles);