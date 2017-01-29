classdef slim_arduino < handle
% To be used with Arduino Uno loaded with 
%'faster_serial_comm.ino'

% This class writes to it's own hdf file, separate from the main task hdf
% file. It also has its own 'run' method that allows it to run continuously
% on its own (occasionally checking the task status through a file named
% 'shared_process.txt' in nexusbmi > data

% 

properties
    cereal;
    first_attempt;
end

methods
    function obj = slim_arduino(com_port)
        obj.first_attempt = true;
        obj.cereal = serial(com_port);
        pause(3);
        set(obj.cereal, 'BaudRate', 115200);
        pause(3);
        try
            disp('Trying to open serial port...')
            fopen(obj.cereal);
            disp('Successfully opened Arduino serial port')
        catch
            disp(strcat('Cannot open serial port: ', com_port));
            disp('Trying again ... ')
            try
                fopen(obj.cereal);
            catch
                disp('Still no luck :( ')
                ME = MException('MyComponent:noSuchVariable', ...
                           'Cannot connect to %s: Instrument not found', com_port);
                throw(ME)
            end
        end
        disp('Pausing 3 sec ... ')
        disp('1'); pause(1);
        disp('2'); pause(1);
        disp('3'); pause(1);       
        
    end
    
    function [d1, axL, azL, hr, ax, ay, az, gx, gy, gz, mx, my, mz, tp] = read(obj)
        %flushinput(obj.cereal);
        
        %Request data (please)
        fprintf(obj.cereal, 'd')
        %pause(1);
        x = 0;
        while obj.cereal.BytesAvailable < 1
            x = x+1;
        end
        %Read data 
        have_d1 = false;
        
        while obj.first_attempt
            pause(1)
            flushinput(obj.cereal)
            fprintf(obj.cereal, 'd')
            d1 = fscanf(obj.cereal, '%d');
            if or(d1 == 0, d1 == 1)
                obj.first_attempt = false;
                have_d1 = true;
            end
        end
        
        if ~have_d1    
            d1 = fscanf(obj.cereal, '%d');
        end
        
        axL = fscanf(obj.cereal, '%d');
        azL = fscanf(obj.cereal, '%d');
        hr = fscanf(obj.cereal, '%d');
        ax = fscanf(obj.cereal);
        ay = fscanf(obj.cereal);
        az = fscanf(obj.cereal);
        
        gx = fscanf(obj.cereal);
        gy = fscanf(obj.cereal);
        gz = fscanf(obj.cereal);
        
        mx = fscanf(obj.cereal);
        my = fscanf(obj.cereal);
        mz = fscanf(obj.cereal);
        
        tp = fscanf(obj.cereal);
        
    end
        
end
end