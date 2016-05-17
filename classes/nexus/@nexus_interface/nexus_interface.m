classdef nexus_interface < handle
    properties
        inst;
        s;
        status;
        serial_port;
        inst_info;
        connected;
        sensing_enabled;
    end    
    
    methods
        function obj = nexus_interface(handles)
            global nex_init nex_inst;
            
            if nex_init
                fprintf('nexus already connected!')            
            else
                %initiate nexus interface
                nex_inst = mdt.neuro.nexus.NexusInstrument.getInstance; 

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

                obj.connected = 0;

                [obj.connected,obj.sensing_enabled]=connect_to_nexus(nex_inst,obj.connected,obj.serial_port);

                if obj.connected
                     % set maintenance timer to 30 sec and supervisory timer to 15 min
                    obj.status = nex_inst.setNexusConfiguration(30,15);
                    if obj.status ~= 0
                        fprintf('setNexusConfiguration failed: %d\n', obj.status);
                    else
                        fprintf('setNexusConfiguration success\n');
                        nex_init = 1;
                    end
                end
            end
        end
        
        function start_stream(obj)
            global nex_inst
            
            %obj.inst.startSensing;
            tmp = nex_inst.stopDataSession;
            pause(1);
            obj.status = nex_inst.startDataSession;
            
            if obj.status == 0
                fprintf('data session enablesd\n');
            else
                fprintf('data session failed to be enabled: %d\n', obj.status);
            end 
        end
        
        function [Data, seq, T] = get_neural(obj, handles)
            global nex_inst
            %D = obj.inst.getDataPacket;
            %iCode = obj.inst.getLastInsResponseCode;
            
            %From Medtronic: Each packet in format of column vector:
            [packet_status,seqnum1,seqnum2,dp1, dp2, dp3, dp4,D]=get_data_packet_pk(nex_inst);
            T = toc(handles.tic);
            fprintf('packet status: %d',packet_status);
            
            if packet_status ~= 0
                %One or two packets received
                current_missed_packets = D.getNumMissedPatterns;
                Data = {dp1, dp2, dp3, dp4};
                
                seq = [seqnum1, seqnum2];
                
            
            else
                %No packets received :( 
                Data = {nan, nan, nan, nan};
                seq = [0, 0];
                
            end
        end
        
        function cleanup_neural(obj)
            global nex_inst
            cleanup_status = nex_inst.stopDataSession;
            nex_inst.stopSensing;
            if (cleanup_status == 0)
                fprintf('stopDataSession success\n');
            else
                fprintf('stopDataSession fail\n');
            end
        end
            
    end
end