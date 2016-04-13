classdef bt_ard < handle
    
properties
    bt;
    analog_readback;
    digital_readback;
end
    
methods
    function obj = bt_ard()
        obj.bt = Bluetooth('HC-05', 1);
        fopen(obj.bt);
        flushinput(obj.bt);
    end
    
    function [d, ax, ay, az] = read(obj)
        fwrite(obj.bt, 1);
        ascii = fread(obj.bt, 18);
        d = ascii2dec(ascii(1:3));
        ax = ascii2dec(ascii(4:8));
        ay = ascii2dec(ascii(9:13));
        az = ascii2dec(ascii(14:18));
    end
    function val = analogRead(obj, chan)
        fwrite(obj.bt, chan);
        ascii = fread(obj.bt,5);
        val = ascii2dec(ascii);
    end
    
    function val = digitalRead(obj, chan)
        fwrite(obj.bt, chan);
        ascii = fread(obj.bt, 3);
        val = ascii2dec(ascii);
    end
    
end

end
                
    