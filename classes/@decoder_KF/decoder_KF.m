classdef decoder_KF < handle
        
    properties
        task_indices_f_ranges
        lp_filter
        decoded_position
        ideal_position
        
        assist_level
        source
        feature_band
        A
        W
        Q
        C
        A_arr
        W_arr
        Q_arr
        C_arr
        R_arr
        S_arr
        T_arr
        EBS_arr
        x_tm_est_arr
        x_ms_est_arr
        
        cov_tm_est_arr
        cov_ms_est_arr
        
        it_cnt
        
        
    end
    
    methods
        function obj = decoder_KF(dec_name, handles)
            %Init
            %obj.it_cnt = handles.iter_cnt;
            obj.assist_level = 0;
            obj.lp_filter = 1;
            
            %Load dec file
            d = load(dec_name);
            
            obj.A = d.decoder.A;
            obj.W = d.decoder.W;
            obj.Q = d.decoder.Q;
            obj.C = d.decoder.C;
            
            its = handles.save_data.tot_task_iters;
            obj.A_arr = zeros(its,1);
            obj.W_arr = zeros(its,1);
            obj.Q_arr = zeros(its,1);
            obj.C_arr = zeros(its,1);
            
            obj.R_arr = zeros(its,1);
            obj.S_arr = zeros(its,1);
            obj.T_arr = zeros(its,1);
            obj.EBS_arr = zeros(its,1);

            obj.x_tm_est_arr = zeros(its, 2);
            obj.x_ms_est_arr = zeros(its, 2);
        
            obj.cov_tm_est_arr = zeros(its, 2,2);
            obj.cov_ms_est_arr = zeros(its, 2,2);
            
            obj.x_tm_est_arr(1,:) = zeros(1,2);
            obj.cov_tm_est_arr(1,:,:) = obj.W;
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
            
            
            % Update Parameters:
            obj=obj.run_RML();
            
            % Run decoder
            obj.decoded_position = obj.run_decoder(task_feat, handles.iter_cnt);
            
            %Apply low pass filter:
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
        
        function ypos = run_decoder(obj, feat, cnt)
            %Get last time update step: 
            pred_x_t = squeeze(obj.x_tm_est_arr(cnt,:))';
            pred_cov_t = squeeze(obj.cov_tm_est_arr(cnt,:,:));
            
            %Measurment Update
            K = pred_cov_t*obj.C'*inv(obj.C*pred_cov_t*obj.C' + obj.Q);
            meas_x_t = pred_x_t + K*(feat - (obj.C*pred_x_t));
            meas_cov_t = (eye(length(obj.C)) - K*obj.C)*pred_cov_t;
            obj.x_ms_est_arr(cnt,:) = meas_x_t;
            obj.cov_ms_est_arr(cnt,:,:) = meas_cov_t;
            
            ypos = meas_x_t;
            
            %Time Update for Next Time: 
            obj.x_tm_est_arr(cnt+1,:) = obj.A*meas_x_t;
            obj.cov_tm_est_arr(cnt+1,:,:) = obj.A*meas_cov_t*obj.A' + obj.W;
            
        end
        
        function obj = run_RML(obj)
        end
    end
end