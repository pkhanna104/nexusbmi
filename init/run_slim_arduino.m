% Script to autonomously run arduino sensor collection and write to an hdf
% file.

function run_slim_arduino(fname, com_port, T)
    %Initialize object:
    obj = slim_arduino(com_port);
    
    % Continue in while loop:
    cont = true;
       
    %Initialize data_dir
    [~, paths] = textread('config.txt', '%s %s',5);
    data_dir = paths{3};
    
    %Start sub_cycle counter
    t = tic;
    
    % Initialize data file: 
   
    fID = fopen(fname, 'w');
    fprintf(fID, '%s, %s, %s, %s, %s, %s, %s, %s\n', 'd1', 'ax','ay','az','axL','azL','ts', 'hr')
    ix = 0;
    
    while cont
        ix = ix + 1;
        
        [d1, ax, ay, az, axL, azL, hr] = obj.read();
        fprintf(fID, '%.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f\n', [d1, ax, ay, az, axL, azL, toc(T), hr]);         
       
        if toc(t) > 5
            %Check file: 'shared_process.txt' in nexusbmi > data
            fileID = fopen(strcat(data_dir, 'shared_process.txt'));
            x = char(fread(fileID));
            if x(1) ~= 'c'
                fclose(fID);
                cont = false;
            end
            fclose(fileID);
            t = tic;
        end
    end
