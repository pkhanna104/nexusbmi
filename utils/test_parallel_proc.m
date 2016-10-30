% Application to randomly generate data at different rates: 
% % Initialization
% parpool;
% c = parcluster;

%Establish communication file: 
tic;
x = 'continue';
fileID = fopen('exp.txt','w');
fprintf(fileID,'%s', x );
fclose(fileID);
toc; 

serial_job = batch('test_parallel_proc_serial', 'matlabpool', 1);

for i = 1:30
    pause(1)
    disp(i)
end

x = 'stop';
fileID = fopen('exp.txt','w');
fprintf(fileID,'%s', x );
fclose(fileID);


%
%Read from test_data.txt
% M = dlmread('test_data.txt', ',', 1, 0);



