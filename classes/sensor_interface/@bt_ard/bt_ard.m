classdef bt_ard < handle
    
properties
    bt;
    analog_readback;
    digital_readback;
end
    
methods
    function obj = bt_ard()
        obj.bt = Bluetooth('HC-05', 1);
        fopen(obj.bt)
        flushinput(obj.bt)
    end
    
    function val = analogRead(obj, chan)
        fwrite(obj.bt, chan);
        ascii = fread(b,5);
        val = ascii2dec(ascii);
    end
    
    function dec = ascii2dec(obj, ascii)
        c = str2num(char(ascii));
        mult = 1;
        dec = 0;
        for i = 1:length(c)
            ci = c(end+1-i);
            dec = dec + (ci*mult);
            mult = mult * 10;
        end
    end
            
    function val = digitalRead(obj, chan)
        fwrite(obj.bt, chan);
        ascii = fread(b, 3);
        val = ascii2dec(ascii);
    end
    
                
    