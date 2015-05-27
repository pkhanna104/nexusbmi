classdef touch_sensor < arduino
    properties
        touch_value
        touch_port = 2;
    end
    
    methods
        function obj = touch_sensor(comPort)
            obj = obj@arduino(comPort);
        end
        
        function val = read(obj)
            val = obj.digitalRead(4); %Assumes pin 4
        end
    end
end