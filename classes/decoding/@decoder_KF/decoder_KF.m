classdef decoder_KF < handle
    
    properties
        task_indices_f_ranges
        lp_filter
        decoded_position
        ideal_position
        
        assist_level
        source
        feature_band
        cursor_buffer
        
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
        mn_sqrt_neur
        
        clda_its
        clda_on
        lambda
    end
    
    methods
        function obj = decoder_KF(dec_name, handles)
            %Init
            if get(handles.clda_box,'Value')
                clda_secs = str2num(get(handles.clda_sec_box,'String'));
                if clda_secs>0
                    obj.clda_its = round(clda_secs)/handles.task.loop_time;
                else
                    obj.clda_its = 0;
                end
            else
                obj.clda_its = 0;
            end
            
            %Get lambda:
            hl = str2num(get(handles.half_life_box,'String'));
            obj.lambda = (.5^(handles.task.loop_time/hl));
            
            %obj.it_cnt = handles.iter_cnt;
            obj.assist_level = 0;
            obj.lp_filter = 1;
            obj.cursor_buffer = zeros(10,1);
            
            %Load dec file
            d = load(dec_name);
            
            obj.A = d.decoder.A;
            obj.W = d.decoder.W;
            obj.Q = d.decoder.Q;
            obj.C = d.decoder.C;
            obj.mn_sqrt_neur = d.decoder.mn_sqrt_neur;
            
            its = handles.save_data.tot_task_iters;
            obj.Q_arr = zeros(its,size(obj.Q,1), size(obj.Q,2));
            obj.C_arr = zeros(its,size(obj.C,1), size(obj.C,2));
            obj.Q_arr(1,:,:) = obj.Q;
            obj.C_arr(1,:,:) = obj.C;
            
            obj.R_arr = zeros(its,size(obj.A,2),size(obj.A,2));
            obj.R_arr(1,:,:) = d.decoder.R_init;
            
            obj.S_arr = zeros(its,size(obj.C,1), size(obj.A,2));
            obj.T_arr = zeros(its,size(obj.C,1), size(obj.C,1));
            obj.EBS_arr = zeros(its,1);
            
            obj.x_tm_est_arr = zeros(its, 2);
            obj.x_ms_est_arr = zeros(its, 2);
            
            obj.cov_tm_est_arr = zeros(its, 2,2);
            obj.cov_ms_est_arr = zeros(its, 2,2);
            
            obj.x_tm_est_arr(1,:) = [0, 1];
            obj.cov_tm_est_arr(1,:,:) = obj.W;
            obj.feature_band = d.decoder.feature_band;
            
            %Establish source
            obj.source = handles.neural_source_name;
            
            %For compatibiility with old decoders:
            if ~isfield(d.decoder,'source')
                d.decoder.source = 'nexus_td';
            end
            
            if and(strcmp(d.decoder.source, 'accel'), ~or(strcmp(obj.source, 'accel'), strcmp(obj.source, 'sim_accel')))
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
            tmp_ft = feat.(handles.feature_extractor.domain);
            if or(strcmp(handles.feature_extractor.domain, 'td'), strcmp(handles.feature_extractor.domain, 'accel'))
                task_ind = find(handles.feature_extractor.task_indices_f_ranges>0);
                feat = tmp_ft(task_ind);
            else
                feat = tmp_ft;
            end
            
            %Normalize features:
            sqrt_task_feat = sqrt(feat);
            task_feat = sqrt_task_feat - obj.mn_sqrt_neur;
            
            % Run decoder
            obj.decoded_position = obj.run_decoder(task_feat, handles.iter_cnt);
            
            % Update Parameters:
            if handles.iter_cnt <= obj.clda_its
                intended_pos = handles.task.target_y_pos;
                obj=obj.run_RML(handles.iter_cnt, task_feat, intended_pos);
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
                (1-alpha)*obj.decoded_position(1:end-1)],1);
            
            
            %Apply low pass filter:
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
        
        function ypos = run_decoder(obj, feat, cnt)
            if strcmp(obj.source, 'nexus_pxx')
                feat = mean(feat);
            end
            %Get last time update step:
            pred_x_t = squeeze(obj.x_tm_est_arr(cnt,:))';
            pred_cov_t = squeeze(obj.cov_tm_est_arr(cnt,:,:));
            
            if isnan(feat)
                disp('skipping this iteration')
                obj.x_tm_est_arr(cnt+1,:) = pred_x_t;
                obj.cov_tm_est_arr(cnt+1,:,:) = pred_cov_t;
                try
                    ypos = obj.x_ms_est_arr(cnt-1,:);
                catch
                    %only if first idx:
                    ypos = pred_x_t;
                end
            else
                
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
            
        end
        
        function obj = run_RML(obj, cnt, feat, intended_x)
            if any([isnan(feat), feat==0, isempty(intended_x)])
                obj.R_arr(cnt+1,:,:) = obj.R_arr(cnt,:,:);
                obj.S_arr(cnt+1,:,:) = obj.S_arr(cnt,:,:);
                obj.T_arr(cnt+1,:,:) = obj.T_arr(cnt,:,:);
                obj.EBS_arr(cnt+1,:,:) = obj.EBS_arr(cnt,:,:);
                obj.C_arr(cnt+1,:,:) = obj.C_arr(cnt,:,:);
                obj.Q_arr(cnt+1,:,:) = obj.Q_arr(cnt,:,:);
            else
                intended_x = [intended_x; 1];
                obj.R_arr(cnt+1,:,:) = obj.lambda*squeeze(obj.R_arr(cnt,:,:))+(intended_x*intended_x');
                squeeze(obj.R_arr(cnt+1,:,:))
                obj.S_arr(cnt+1,:,:) = obj.lambda*squeeze(obj.S_arr(cnt,:,:))' +(feat*intended_x');
                obj.T_arr(cnt+1,:,:) =obj.lambda*squeeze(obj.T_arr(cnt,:,:)) + (feat*feat');
                obj.EBS_arr(cnt+1) = obj.lambda*obj.EBS_arr(cnt) + 1;
                obj.C_arr(cnt+1,:,:) = squeeze(obj.S_arr(cnt+1,:,:))'*inv(squeeze(obj.R_arr(cnt+1,:,:)));
                obj.Q_arr(cnt+1,:,:) = (1/obj.EBS_arr(cnt+1))*(squeeze(obj.T_arr(cnt+1,:,:))-...
                    ((squeeze(obj.C_arr(cnt+1,:,:))'*squeeze(obj.S_arr(cnt,:,:)))));
            end
            obj.C = squeeze(obj.C_arr(cnt+1,:,:))';
            obj.Q = squeeze(obj.Q_arr(cnt+1,:,:));
            
            if any(isnan(obj.C))
                disp('stop')
            end
            
        end
    end
end