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
end

methods
    function obj = slim_arduino(com_port)
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
    
    function [d1, ax, ay, az, axL, azL] = read(obj)
        %flushinput(obj.cereal);
        
        %Request data (please)
        fprintf(obj.cereal, 'd')
        %pause(1);
        x = 0;
        while obj.cereal.BytesAvailable < 1
            x = x+1;
        end
        %Read data 
        d1 = fscanf(obj.cereal, '%d');
        ax = fscanf(obj.cereal, '%d');
        ay = fscanf(obj.cereal, '%d');
        az = fscanf(obj.cereal, '%d');
        axL = fscanf(obj.cereal, '%d');
        azL = fscanf(obj.cereal, '%d');
    end
        
end
end