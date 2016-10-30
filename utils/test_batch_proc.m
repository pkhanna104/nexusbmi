f = figure(); 
x_buffer = zeros(100, 1);
y_buffer = zeros(100, 1);
ax = plot(x_buffer, y_buffer, 'b.-');

spmd
    T = tic;

for i = 1:1000
    x_buffer = [x_buffer(2:end); i/1000];
    y_buffer = [y_buffer(2:end); sin(2*pi*i/1000*20)];
    set(ax, 'XData', x_buffer)
    set(ax, 'YData', y_buffer)
    pause(.01)
end
    
    