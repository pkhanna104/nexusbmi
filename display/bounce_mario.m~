function bounce_mario(handles, tm, f)
%Bounce Mario for two second, 20Hz:
%tm = 2;
t =linspace(0,tm,20*tm);
%f = 2;
y = sin(f*2*pi*t);

for i=1:length(t)
    handles = plot_mario([y(i), 0], handles);
    pause(1/20)
end