function handles = plot_mario(loc, handles)

    if strcmp(handles.task.state, 'tapping')
        loc = [100 100];
    end
    
    old_x = mean(get(handles.mario.im,'Xdata'));
    old_y = mean(get(handles.mario.im,'Ydata'));
    
    set(handles.mario.im,'Xdata',get(handles.mario.im,'Xdata')-old_x + loc(2));
    set(handles.mario.im,'Ydata',get(handles.mario.im,'Ydata')-old_y + loc(1));
    
end