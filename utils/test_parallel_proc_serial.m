com_port = 'COM3';
cereal = serial(com_port);
pause(2);
set(cereal, 'BaudRate', 115200);
pause(2);
fopen(cereal);
pause(2);
cont = true;
t = tic;
T = tic;

fileID2 = fopen('test_data.txt', 'w');
%fprintf(fileID2,'%s', 'start' );

sum = 0;
while cont
    fprintf(cereal, 'd')
    pause(.001);
    %Read data 
    d1 = fscanf(cereal, '%d');
    ax = fscanf(cereal, '%d');
    ay = fscanf(cereal, '%d');
    az = fscanf(cereal, '%d');
    axL = fscanf(cereal, '%d');
    azL = fscanf(cereal, '%d');
    sum = d1 + ax + ay + az + axL + azL;
    %disp(sum)
    
    fprintf(fileID2,'%.5f, %.5f\n', [toc(T), sum] );

    
    if toc(t) > 5
        fileID = fopen('exp.txt');
        x = char(fread(fileID));
        if x(1) ~= 'c'
            cont = false;
            fclose(fileID2);
        end
        fclose(fileID);
        t = tic;
    end
end