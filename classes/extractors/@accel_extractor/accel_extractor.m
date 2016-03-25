classdef accel_extractor < feature_extractor
% mtm method for power spectrum extraction
    
    properties
        task_indices_f_ranges
        domain
    end
    
    methods
        function obj = accel_extractor(extractor_params)
            obj.task_indices_f_ranges = [0, 1, 0, 0]; %Accelerometer in buffer
            obj.domain = 'accel';
        end                        

        function features = extract_features(obj,recent_neural)
            features = struct();
            features.accel = zeros(1,length(recent_neural));
            %features.fd = zeros(1,length(recent_neural));
            for i=1:length(recent_neural)
                if obj.task_indices_f_ranges(i)
                    %Acc feature:
                    features.accel(i) = mean(sum(recent_neural{i}, 1));
                else
                    features.accel(i) = sum(abs(recent_neural{i}));
                end
            end
        end    
    end
end