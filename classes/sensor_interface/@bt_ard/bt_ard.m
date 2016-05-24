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
        set(obj.bt, 'Timeout', .1);
    end
    
    function [d1, d2, ax, ay, az] = read(obj)
        flushinput(obj.bt);
        fwrite(obj.bt, 1);
        try
            ascii = fread(obj.bt, 21);
            d1 = ascii2dec(ascii(1:3));
            d2 = ascii2dec(ascii(4:6));
            ax = ascii2dec(ascii(7:11));
            ay = ascii2dec(ascii(12:16));
            az = ascii2dec(ascii(17:21));
        catch
            d1 = nan;
            d2 = nan;
            ax = nan;
            ay = nan;
            az = nan;
        end
    end
    
    function val = analogRead(obj, chan)
        % Deprecated
        fwrite(obj.bt, chan);
        ascii = fread(obj.bt,5);
        val = ascii2dec(ascii);
    end
    
    function val = digitalRead(obj, chan)
        %Deprecated
        fwrite(obj.bt, chan);
        ascii = fread(obj.bt, 3);
        val = ascii2dec(ascii);
    end
    
end

end
                
    