s = serial('COM3');
set(s, 'BaudRate', 115200);
fopen(s)

ts = 10000;
y = zeros(ts, 3);
y2 = zeros(ts, 2);

tch = zeros(ts, 1);
T = [];

for i = 1:10000
    t = tic;
    fprintf(s, 'd');
    %out = fread(s, 20);
    %a = num2str(ascii2dec(out));
    tch(i) = fscanf(s, '%d');
    y(i, 1) = fscanf(s, '%d');
    y(i, 2) = fscanf(s, '%d');
    y(i, 3) = fscanf(s, '%d');
    y2(i, 1) = fscanf(s, '%d');
    y2(i, 2) = fscanf(s, '%d');
    %pause(0.02)
    T = [T toc(t)];
    %pause(1/50 - toc(t));
end