classdef sim_nexus_interface < handle
    properties
        inst;
        s;
        status;
        serial_port;
        inst_info;
        connected;
        sensing_enabled;
        cnt1=1;
        cnt3=2;
        time_series;
        time_cnt;
    end    
    
    methods
        function obj = sim_nexus_interface(handles)
            global nex_init nex_inst;
            
            if nex_init
                fprintf('nexus already connected')
            
            else
                %init nexus interface:
                nex_inst = struct();

                % Find current serial ports:
                if isfield(handles, 'nexus_serial_port')
                    obj.serial_port = handles.nexus_serial_port;
                else
                    try
                        obj.serial_port = get(handles.serial_port_box, 'String');
                    catch
                        errordlg('Serial port not found','Nexus Error');
                    end
                end
                obj.connected = 1;
                obj.sensing_enabled = 1;
                
                obj.status = 0;
                nex_init = 1;
            end
            %C = load([handles.root_path '/test_data/brpd04.mat']);
            %obj.time_series = C.C{3};
            t = linspace(0,60, 60/(1/422));
            obj.time_series = 5*sin(2*pi*15*t) + rand(1,length(t));
            obj.time_cnt = 1;
            
        end
        
        function start_stream(obj)
            global nex_inst
%             nex_inst.startSensing =1;
%             nex_inst.startDataSession =1;
        end
        
        function [Data, seq] = get_neural(obj, handles)
            width = handles.feature_extractor.width;
            %D = obj.inst.getDataPacket;
            %Data = D.getData;
            
            Data = {rand(width,1), rand(width,1)};
            %disp(rem(obj.time_cnt, 40))
%             if rem(obj.time_cnt, 40) > 20
%                 x = obj.time_series(1:width);
%             else
%                 x = rand(width,1);
%             end
%             
%             catch
%                 %Recycle through file:
%                 obj.time_cnt = 1;
%                 x = obj.time_series(obj.time_cnt:obj.time_cnt+width);
%             end
            
            %Data = {x, x};

            obj.time_cnt = obj.time_cnt + 1;
            seq = [obj.cnt1, obj.cnt3];
            obj.cnt1 = obj.cnt1+2;
            obj.cnt3 = obj.cnt3+2;
            
        end
    end
end