% b = Bluetooth('HC-05',1);
% fopen(b)
flushinput(b)
cnt = 0;
while cnt < 1000
    flushinput(b)
%     fwrite(b,20)
%     disp(char(fread(b,7)));
%     pause(1)
    fwrite(b, 8)
    ascii = fread(b,3);
    dec = ascii2dec(ascii);
    disp(dec)
    %pause(.1)
    cnt = cnt + 1;
    pause(1)
end
