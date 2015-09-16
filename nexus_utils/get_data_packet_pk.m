function [packet_status,seqnum1,seqnum2,datapacket1,datapacket2, datapacket3,datapacket4, D]=get_data_packet(inst)

packet_status=0;
seqnum1 = 0;
seqnum2 = 0;
datapacket1 = 0;
datapacket3 = 0;
    
%Get the data and figure out what was inside of it
D = inst.getDataPacket;

% iCode = inst.getLastInsResponseCode;
% if (iCode == -1 || iCode == 105) % check to be sure it is in session
%     nxsStatus = inst.getNexusStatus;
%     if inst.getLastInsResponseCode == -1
%         disp('Device Powered off. Or Antenna not in range. Please restart')
%         return
%     end
%     if ~strcmp(nxsStatus.getState,'MAINTENANCE_ENABLED') 
%         inst.startDataSession; % not in session so try to start a new session
%         if inst.getLastInsResponseCode ~= 0
%             fprintf('System problem %d\n',inst.getLastInsResponseCode);
%             return
%         end
%     end
%     D = inst.getDataPacket; % try again to get the data packet
% end


if isempty(D)  
    % No packet was returned
    % display the reason it is empty
    fprintf('Empty Packet = %d,', inst.getLastInsResponseCode()); 

else
    Data = D.getData;
    seqnum1=D.getPatternNum1;
    seqnum2=D.getPatternNum2;
    
    if seqnum1>seqnum2 && seqnum1 ~= 255 
        %only first packet is valid
        datapacket1=double(Data{1,1}(1:length(Data{1,1})/2)); 
        datapacket2 = double(Data{2,1});
        datapacket3=double(Data{3,1}(1:length(Data{3,1})/2));
        datapacket4 = double(Data{4,1});
        packet_status=1;
    else
        %two valid packets received         
        datapacket1=double(Data{1,1});
        datapacket2 = double(Data{2,1});
        datapacket3=double(Data{3,1});
        datapacket4 = double(Data{4,1});
        packet_status=2;
    end
    fprintf('received seqnum1: %d, seqnum2: %d\n',seqnum1,seqnum2);
end