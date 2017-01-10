classdef decoder_simple < handle
    % mtm method for power spectrum extraction
    
    properties
        task_indices_f_ranges
        mu
        std
        lp_filter
        decoded_position
        ideal_position
        assist_level
        source
        feature_band
        cursor_buffer
    end
    
    methods
        function obj = decoder_simple(dec_name, handles)
            %Init
            obj.assist_level = 0;
            obj.lp_filter = 1;
            obj.cursor_buffer = zeros(10,1);
            
            %Load dec file
            d = load(dec_name);
            obj.mu = d.decoder.mean;
            obj.std = d.decoder.std;
            obj.feature_band = d.decoder.feature_band;
            
            %Establish source
            obj.source = handles.neural_source_name; 
            
            %For compatibiility with old decoders: 
            if ~isfield(d.decoder,'source') 
                if ~isempty(strfind(dec_name, 'pxx'))
                    d.decoder.source = 'nexus_pxx';
                else
                    d.decoder.source = 'nexus_td';
    
                end
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
                task_feat = mean(feat.td(task_ind));
            elseif strcmp(handles.feature_extractor.domain, 'pxx')
                try
                    task_feat = mean(feat.fd);
                catch
                    task_feat = mean(feat.pxx);
                end
            end
            
            % Run decoder
            obj.decoded_position = obj.run_decoder(task_feat);
                        
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
            
            %Ignores nans: 
            ypos = nansum([alpha*obj.ideal_position; ...
                (1-alpha)*obj.decoded_position(1:end-1)],1);
            
            if isnan(obj.decoded_position(1:end-1))
                disp(' Decoded pos is nan! ')
            end
            
             % low pass filter:
            if obj.lp_filter > 1
                earliest_ix = obj.lp_filter - 2; %because matlab indexing doesn't make sense...
                comp_dat = [ypos; obj.cursor_buffer(end-earliest_ix:end)];
                ypos = (1/obj.lp_filter)*sum(comp_dat);
            end
            
            % Clip cursor to stay on screen:
            if ypos > 10
                ypos=10;
            elseif ypos < -10
                ypos = -10;
            end
            
            handles.window.cursor_pos(2) = ypos;
            obj.cursor_buffer = [obj.cursor_buffer(2:end); ypos];
            
        end
        
        function ypos = run_decoder(obj, feat)
            ypos = (feat - obj.mu)/obj.std;
            ypos = [ypos, 1];
            
        end
    end
end