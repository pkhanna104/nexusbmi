classdef sim_accel < handle
    properties
        sim_acc;
        time_cnt
        batch
    end    
    
    methods
        function obj = sim_accel(handles)
            x = load('dat102715c_');
            obj.sim_acc = cell2mat(x.dat.rawdata_power_ch2);
            rnd_ix = randperm(size(obj.sim_acc,2));
            obj.sim_acc = repmat(obj.sim_acc(:,rnd_ix), [1, 1000]);
            obj.time_cnt = 1;
            obj.batch = 5;
        end
        
        function start_stream(obj)
            disp('Starting Arduino Streaming');
        end
        
        function [Data, seq, T] = get_neural(obj, handles)
            %D = obj.inst.getDataPacket;
            %Data = D.getData;
            T = toc(handles.tic);
            obj.time_cnt = obj.time_cnt + 1;
            Data = {[0], [obj.sim_acc(:,(obj.time_cnt*obj.batch):((obj.time_cnt+1)*obj.batch))],[0],[0]};
            seq = [0,0];
            %seq = [obj.cnt1, obj.cnt3];
            %obj.cnt1 = obj.cnt1+2;
            %obj.cnt3 = obj.cnt3+2;
            
        end
    end
end