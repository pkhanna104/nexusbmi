function [connected,sensing_enabled]=connect_to_nexus(inst,connected,serial_port)

sensing_enabled=false;

%Connect to the device
connectRsp = inst.connect(mdt.neuro.nexus.SerialConnection(serial_port));
if (connectRsp == 0) 
    % First check the current NxsD status 
    % wait for NxsD to connect to the INS
    nxsReady = false;
    while ~nxsReady % loop until connected to INS
        nxsStatus = inst.getNexusStatus();
        if nxsStatus ~= 0 
            if strcmp(nxsStatus.getState,'INS_CONNECTED') 
                % Now connected to the INS
                nxsReady=true;
                connected=true;
                
                %NICKI - this code is new to set sensing_enabled in this
                %case also.
                info = inst.getInsInfo(); % get the INS configuration and state
                if info ~= 0
                    if strcmp(info.getSensingState,'ENABLED') 
                        sensing_enabled = true;
                    end
                else
                    fprintf('getInsInfo() problem %d - \n',inst.getLastInsResponseCode);
                    disp(inst.getLastNexusResponseCode);
                end    
                
            elseif strcmp(nxsStatus.getState,'MAINTENANCE_ENABLED')
                % already in streaming mode
                nxsReady=true;
                sensing_enabled = true;
                connected=true;
            end
            if nxsStatus.getBatteryPercent() <= 0.5
                disp('!Battery at less than 50%'); % notify that the battery may be low
            end
            fprintf('STS Ver %d.%d',nxsStatus.getMajorVersion(),nxsStatus.getMinorVersion());
            fprintf(' Batt %3.2f ',nxsStatus.getBatteryPercent()); 
            fprintf(' Host Timeout %d minutes',nxsStatus.getHostTimeoutMinutes());
            fprintf(' Maint Timeout %d seconds\n',nxsStatus.getMaintenanceTimeoutSeconds());
            disp(nxsStatus.getState())
            pause(1)
        else
            if inst.getLastInsResponseCode == -1
                disp('Device Powered off. Or IrDA not in range. Please restart')
                return
            end
        end
    end
else
    % PORT_NOT_FOUND = 1; PORT_BUSY = 2; PORT_NULL = 3;
    fprintf('Port Connect Failed: %d\n', connectRsp)
    
    % NICKI - this call to disconnect is added...
    inst.disconnect; % just in case it failed because of second call without disconnect
end

