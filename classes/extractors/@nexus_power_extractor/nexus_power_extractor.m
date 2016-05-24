classdef nexus_power_extractor < feature_extractor
% mtm method for power spectrum extraction
    
    properties
        width;    % running average filter width (# of pts)
        width_t;  % running average filter width (in seconds)
        f_ranges;    % freq ranges
        task_f_ranges; 
        task_indices_f_ranges; 
        range_inds;
        params;   % struct containing parameters for mtm
        used_chan_array;  % cell array of arrays of used channels for each range
        chnfeat_index; 
        ftfeat_index;
        f_max = 150;
        last_features;
        beta_pow_chan;
        domain; %td or pxx for time domain or power channel
        nfft;
    end
    
    methods
        function obj = nexus_power_extractor(extractor_params)
            %Chan idx
            obj.used_chan = extractor_params.used_chan;
            
            %Time 
            obj.width = round(extractor_params.width_t/1000*extractor_params.fs);
            
            %Get frequencies 
            test = zeros(obj.width,1);
            
            obj.fs         = extractor_params.fs;
            obj.width_t    = extractor_params.width_t;
            
            
            %MTM 
            %obj.params     = struct('fpass',[0 obj.f_max],'Fs',obj.fs,'tapers',[3 5]);
            %[~,f] = mtspectrumc(double(test),obj.params);
            
            %PWELCH
            obj.nfft=max(2^(nextpow2(obj.width)),obj.width);
            [~,f] = pwelch(test,obj.width-1,[],obj.nfft,obj.fs); 
            
            % nfft=max(2^(nextpow2(obj.width)),obj.width);
            % [f,~]=getfgrid(extractor_params.fs,nfft,[0 obj.f_max]);
            

            %Get domain: 
            if isfield(extractor_params,'domain')
                obj.domain=extractor_params.domain;
            elseif isfield(extractor_params, 'nexus_domain')
                obj.domain=extractor_params.nexus_domain;
            else
                obj.domain = 'td';
            end
            % frequency range indices
            bandc = {};
            for c = 1:size(extractor_params.f_ranges,1)
                bandc{c} = find((f >= extractor_params.f_ranges(c,1)) & ...
                    (f <= extractor_params.f_ranges(c,2)));
            end
                        
            obj.range_inds = bandc;        
            obj.f_ranges     = extractor_params.f_ranges;
            obj.n_features = size(obj.f_ranges,1);
            
            obj.last_features = struct();
            obj.last_features.pxx = [0];
            obj.last_features.td = zeros(obj.n_features,1);
            obj.task_f_ranges = extractor_params.task_f_ranges;
            
            disp(strcat('n_features ',num2str(obj.n_features)));
            %obj.used_chan_array = {}; % have every frequency use same channels for now
%             
%             for c = 1:size(obj.f_ranges,1)
%                 obj.used_chan_array{c,1} = extractor_params.used_chan;
%             end
            
            obj.chnfeat_index = repmat(obj.used_chan(:),(size(obj.f_ranges,1)),1);
            obj.ftfeat_index = reshape(repmat(1:size(obj.f_ranges,1),length(obj.used_chan),1),...
                size(obj.f_ranges,1)*length(obj.used_chan),1);
          
           
            obj.task_indices_f_ranges = zeros(length(obj.f_ranges),1);
            
            %Which is the task relevant f_range?
            for i =1:size(obj.f_ranges,1)
                for j = 1:size(obj.task_f_ranges,1)
                    if obj.f_ranges(i,:) == obj.task_f_ranges(j,:)
                        obj.task_indices_f_ranges(i) = 1;
                    end
                end
            end
            
        end                        

        function features = extract_features(obj,recent_neural)
            features = struct();
            
            if any([isnan(recent_neural{obj.used_chan}); isempty(recent_neural{obj.used_chan})])
                try
                    features.(obj.domain) = obj.last_features.(obj.domain);
                catch
                    features.(obj.domain) = obj.last_features;
                end
                disp('last features');
            else
                %x = recent_neural.read(obj.width)';

                %Index into cell array of 'recent_neural'
                %data = recent_neural{obj.used_chan};
                
                %M1 channel: 
                data = recent_neural{obj.used_chan};
                %beta = recent_neural{4};
                
                if (obj.f_ranges(1,2)-obj.f_ranges(1,1) < 10)
                    obj.params.pad = 2;
                end


                %[S,f] = mtspectrumc(x(:,ind_chan),obj.params);
                %Data input form: samples x channels/trials
                [dr, dc] = size(data);
                if dc==1
                    data = data';
                end
                %disp('data2');
                %size(data)
                
                
                if strcmp(obj.domain,'td')
                    [S,~] = pwelch(data,obj.width-1,[],obj.nfft,obj.fs);
                    %[Pxx,F] = pwelch(X,WINDOW,NOVERLAP,F,Fs)
                    %[S,~] = mtspectrumc(data,obj.params);

                    % compute average power of each band of interest
                    % pow = zeros(size(obj.ranges,1),size(S,2));
                    
                    features.(obj.domain) = zeros(obj.n_features,1);
                    
                    cur = 0;
                    for c = 1:size(obj.f_ranges,1)
                        temp = S(obj.range_inds{c},:);    
                        temp = sum(temp,1); %SUM across frequencies
                        %temp = mean(temp,1) <--- this is what Sid/Kelvin used
        %                 if obj.log_flag
        %                     feat = log10(temp);
        %                 else
        %                     feat = temp;
        %                 end : MOVE LOG TO calc_lfp_cursor
                        feat = temp;

                        %This is stupidly complicated, but basically, each
                        %'feat' is  a single number, so features is an
                        % [n_iter x 100] matrix  
                        features.(obj.domain)( (1 : length(feat)) + cur ) = feat;
                        cur = cur + length(feat);                                
                    end

                    if cur ~= obj.n_features
                        error('Incorrect number of features')
                    end;
                    
                elseif strcmp(obj.domain, 'pxx')
                    features.(obj.domain) = data;
                end
                obj.last_features = features.(obj.domain);
                    
            end
        
        end    
    end
end