function play_sig(dev_num, file_fs, vector_of_data)

devices = daq.getDevices; 
s = daq.createSession('ni'); 

% Assume only 1 device: 
dev = devices(dev_num);
ID = dev.ID;

% Add analog output channel
addAnalogOutputChannel(s, ID, 0, 'Voltage');

% Setup Rate: 
s.Rate = file_fs;

sec = length(vector_of_data)/file_fs;
reps = ceil(60/sec);

output_rep = repmat(vector_of_data, [reps, 1]);

x = min([10000, length(output_rep)]);

while 1
    queueOutputData(s, output_rep(1:x,:));
    s.startForeground;
end