classdef accel < handle
    properties
        ard;
        ard_buff;
        com_port;
        time_cnt;
        sim_acc;
    end    
    
    methods
        function obj = accel(handles)
            init_ard = 0;
            if isprop(handles.task,'ard')
                try
                    if isnan(handles.task.ard)
                        init_ard = 1;
                    end
                catch
                    obj.ard = handles.task.ard;
                end
            end
            if init_ard
                obj.com_port = get(handles.arduino_comport, 'String');
                delete(instrfind({'Port'},{obj.com_port}))
                obj.ard = arduino(obj.com_port);
            end
                
            %C = load([handles.root_path '/test_data/brpd04.mat']);
            %obj.time_series = C.C{3};
            %t = linspace(0,60, 60/(1/422));
            %obj.time_series = 5*sin(2*pi*15*t) + rand(1,length(t));
            obj.time_cnt = 1;
            obj.ard_buff = struct();
            obj.ard_buff.cap = [];
            obj.ard_buff.accel = [];
            
            
        end
        
        function start_stream(obj)
            disp('Starting Arduino Streaming');
        end
        
        function [Data, seq, T] = get_neural(obj, handles)
            %D = obj.inst.getDataPacket;
            %Data = D.getData;
            
            T = toc(handles.tic);
            obj.time_cnt = obj.time_cnt + 1;
            Data = {[obj.ard_buff.cap], [obj.ard_buff.accel],[0],[0]};
            obj.ard_buff.cap = [];
            obj.ard_buff.accel = [];
            seq = [0,0];
            %seq = [obj.cnt1, obj.cnt3];
            %obj.cnt1 = obj.cnt1+2;
            %obj.cnt3 = obj.cnt3+2;
            
        end
    end
end