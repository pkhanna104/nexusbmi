clc

javaaddpath('C:\Nexus\jssc.jar')
javaaddpath('C:\Nexus\nexus.jar')
javaclasspath ;
inst = mdt.neuro.nexus.NexusInstrument.getInstance;

serial_port = 'COM5';
connected=false;

%Connect to device
[connected, sensing_enabled]=connect_to_nexus(inst,connected,serial_port);
if connected % don't continue if the INS connection failed
   
    % set maintenance timer to 30 sec and supervisory timer to 15 min
    status = inst.setNexusConfiguration(30,15);
    if status ~= 0
        fprintf('setNexusConfiguration failed: %d\n', status);
    else
        fprintf('setNexusConfiguration success\n');
    end

    %Enable sensing if necessary
    if ~sensing_enabled
        while sensing_enabled==false;
            status=inst.startSensing;
            if status==0
                sensing_enabled=true;
                fprintf('sensing enabled\n');
            else
                fprintf('sensing failed to be enabled: %d\n', status);
                pause(1)
            end
        end
    end    
end

