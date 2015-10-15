classdef decoder_simple < handle
    % mtm method for power spectrum extraction
    
    properties
        task_indices_f_ranges
        mean
        std
        lp_filter
        decoded_position
        ideal_position
        assist_level
        source
        feature_band
    end
    
    methods
        function obj = decoder_simple(dec_name, handles)
            %Init
            obj.assist_level = 0;
            obj.lp_filter = 1;
            
            %Load dec file
            d = load(dec_name);
            obj.mean = d.decoder.mean;
            obj.std = d.decoder.std;
            obj.feature_band = d.decoder.feature_band;
            
            %Establish source
            obj.source = handles.neural_source_name; 
            
            %For compatibiility with old decoders: 
            if ~isfield(d.decoder,'source')
                d.decoder.source = 'nexus_td';
            end
            
            if and(strcmp(d.decoder.source, 'accel'), ~strcmp(obj.source, 'accel'))
                error('Decoder is for an accelerometer source')
            else
                %Allow for simNexus and Nexus to use same decoders if
                %domain is same:
                ext = obj.source(end-1:end);
                ext_dec = d.decoder.source(end-1:end);
                if ~strcmp(ext,ext_dec)
                    error(strcat('Source is ',obj.source, ' but Decoder Source is ',d.decoder.source));
                end
            end
              
        end
        
        function handles = calc_cursor(obj, feat, handles)
            % feat is a lfp band x 1 array if time domain
            % else if a pxx channel
            if strcmp(handles.feature_extractor.domain, 'td')
                task_ind = find(handles.feature_extractor.task_indices_f_ranges>0);
                task_feat = mean(feat(task_ind));
            elseif strcmp(handles.feature_extractor.domain, 'pxx')
                task_feat = mean(feat);
            end
            
            % Run decoder
            % scale task feat:
            obj.decoded_position = obj.run_decoder(task_feat);
            
            % low pass filter:
            if obj.lp_filter > 1
                earliest_ix = max([1, handles.iter_cnt - obj.lp_filter + 1]);
                comp_dat = [obj.decoded_position handles.save_data.cursor(earliest_ix:handles.iter_cnt-1)'];
                obj.decoded_position = (1/obj.lp_filter)*sum(comp_dat);
            end
            
            % Add assist:
            if ~isempty(handles.task.target_y_pos)
                obj.ideal_position = handles.task.target_y_pos;
            else
                obj.ideal_position = nan;
            end
            
            %If no target, don't weight ideal position
            if isnan(obj.ideal_position)
                alpha = 0;
            else
                alpha = obj.assist_level/100;
            end
            
            ypos = nansum([alpha*obj.ideal_position; ...
                (1-alpha)*obj.decoded_position],1);
            
            % Clip cursor to stay on screen:
            if ypos > 10
                ypos=10;
            elseif ypos < -10
                ypos = -10;
            end
            
            handles.window.cursor_pos(2) = ypos;
            
        end
        
        function ypos = run_decoder(obj, feat)
            ypos = (feat - obj.mean)/obj.std;
            
        end
    end
end