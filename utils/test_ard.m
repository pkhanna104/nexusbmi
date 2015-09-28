function acc = test_ard(com_port, fs)
delete(instrfind({'Port'},{com_port}))
acc = zeros(60*fs, 3);

ard = arduino(com_port);
for i = 1:60*fs
    acc(i, 1) = ard.analogRead(0);
    acc(i, 2) = ard.analogRead(1);
    acc(i, 3) = ard.analogRead(3);
    pause(1/fs)
end         

figure;
plot(acc)