%basic sensing data to retrieve data and 

STN_data = NaN(1,200);
M1_data = NaN(1,200);
data_packets = NaN(1,2);
missed_packets = NaN(1,1);
desired_num_runs = 200;
packetTime = 0;

tic

ret_num = 1;
while ret_num < desired_num_runs
    fprintf('ret_num: %d,', ret_num);
    if ret_num == 1
        status = inst.startDataSession;
        if status==0
            fprintf('data session enabled\n');
        else
            fprintf('data session failed to be enabled: %d\n', status);
            return
        end
    end
    
    [packet_status,seqnum1,seqnum2,datapacket1,datapacket3,D]=get_data_packet_simple(inst);
    
    if packet_status ~= 0
        % one or two packets received
        packetTime = clock;
        Data = D.getData;
        current_missed_packets = D.getNumMissedPatterns;

        if ret_num == 1
            STN_data = [ datapacket1'];
            M1 = [datapacket3'];
            data_packets = [seqnum1 seqnum2];
            missed_packets = [current_missed_packets];
        else
            STN_data = [STN_data datapacket1'];
            M1_data = [M1_data datapacket3'];
            data_packets = [data_packets seqnum1 seqnum2];
            missed_packets = [missed_packets current_missed_packets];
        end
    else
        elapsedTime = etime(clock,packetTime);
        fprintf('no data packets recieved. elapsedTime since last packet: %d\n', elapsedTime);
        if elapsedTime > 25 % must get packet in less than 30 seconds
            % stop the session to avoid issue in the NxsD ver 2.7 code
            fprintf('25 seconds without successful data retrieval - stopping real-time');
            ret_num=desired_num_runs; % exit this loop
        end
    end
    ret_num = ret_num +1;
    clear D Data seqnum1 seqnum2 datapacket1 datapacket3 current_missed_packets;
end

status = inst.stopDataSession;
if (status == 0)
    fprintf('stopDataSession success\n');
else
    fprintf('stopDataSession fail\n');
end

status = inst.stopSensing;
if (status == 0)
    fprintf('stopSensing success\n');
else
    fprintf('stopSensing fail\n');
end