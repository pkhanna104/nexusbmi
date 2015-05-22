function intro_display(handles)

bounce_mario(handles, 1, 1)
T = [];

str ='\fontsize{30} \color{white} Get Ready...';
T(1) = text(-9,8,str,'parent',handles.window.ax);

bounce_mario(handles, 1, 1)

% str ='\fontsize{30} \color{white} Get Excited...';
% T(2) = text(-9,5,str,'parent',handles.window.ax);
T(2)=0;

bounce_mario(handles, 1, 2)

str ='\fontsize{30} \color{white} 3...';
T(3) = text(-9,2,str,'parent',handles.window.ax);

bounce_mario(handles, .5, 2)

str ='\fontsize{30} \color{white} 2...';
T(4) = text(-9,0,str,'parent',handles.window.ax);

bounce_mario(handles, .5, 2)

str ='\fontsize{30} \color{white} 1...';
T(5) = text(-9,-2,str,'parent',handles.window.ax);

bounce_mario(handles, .5, 2)

str ='\fontsize{30} \color{white} GO! ';
T(6) = text(-9,-4,str,'parent',handles.window.ax);

for i=1:length(T)
    if i~=2
        delete(T(i))
    end
end

end