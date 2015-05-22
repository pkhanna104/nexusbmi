function [final_targ_locs, trim_rew_inds] = get_targ_loc(dat)
    rew_inds = [];
    for i=1:length(dat.state)
        if strcmp(dat.state{i}, 'reward')
            rew_inds = [rew_inds i];
        end
    end

    targ_inds = [];
    for i=1:length(dat.state)
        if strcmp(dat.state{i}, 'target')
            targ_inds = [targ_inds i];
        end
    end

    wait_inds = [];
    for i=1:length(dat.state)
        if strcmp(dat.state{i}, 'wait')
            wait_inds = [wait_inds i];
        end
    end

    targ_inds = targ_inds - 1;
    rew_inds = rew_inds - 1;
    wait_inds = wait_inds - 1;

    
    % figure;
    % hold all;
    % plot(dat.cursor,'.-')
    % plot(dat.decoded_pos)
    % legend('Cursor','Decoded_Pos')
    % plot(dat.assist_level,'c.-')
    % plot(rew_inds,5,'r.')
    % plot(targ_inds,5,'g.')
    % plot(wait_inds,5, 'k.')

    %Remove 2nd and 3rd index:
    last_idx = 1;
    trim_rew_inds = [];
    for i=1:length(rew_inds)
        if rew_inds(i) - last_idx > 2
            trim_rew_inds = [trim_rew_inds rew_inds(i)];
        end
        last_idx = rew_inds(i);
    end

    %plot(trim_rew_inds, 6, 'c.')

    %% Targ Location vector
    targ_locs = [-6, -2, 2, 6];
    dat.targ_locs = zeros(length(dat.cursor),1);

    last_targ_loc = 1;
    for i=1:length(trim_rew_inds)
        cur = dat.cursor(trim_rew_inds(i));
        d2 = abs(targ_locs - cur);
        j = find(d2<2);
        if isempty(j)
            disp('error -- no target?');
            trim_rew_inds(i)
            plot([trim_rew_inds(i), trim_rew_inds(i)],[-6, 6],'k-')
        elseif length(j)>1
            disp('errror == tie');
        else
            dat.targ_locs(last_targ_loc+1:trim_rew_inds(i)+2) = targ_locs(j);
            last_targ_loc = trim_rew_inds(i)+2;
        end
    end
    final_targ_locs = dat.targ_locs;

%     plot(dat.targ_locs,'m-')

% %% Recreate 'decoded_pos':
% %From features: 3rd features
% 
% ft = dat.features(:,3);
% 
% %Get zeros:
% ix_zer = find(ft==0);
% act_curs = dat.cursor;
% 
% %Remove assist:
% alpha = dat.assist_level/100;
% unass = (act_curs(ix_zer) - (alpha(ix_zer).*dat.targ_locs(ix_zer)))./(1-alpha(ix_zer));
% 
% %Remove known cursor:
% ft_int = zeros(length(ix_zer),1);
% 
% for i=1:length(ft_int)
%     lp = dat.lp_filter(ix_zer(i));
%     ft_int(i) = (unass(i)*lp) - sum(act_curs(i-lp+1));
% end
% 
% ft(ix_zer) = ft_int;
% 
% lp_filter = dat.lp_filter;
% assist = dat.assist_level;
% 
% cursor = zeros(1,length(ft));
% decoded_position = zeros(1, length(ft));
% lp_data = zeros(1, length(ft));
% % decoded_position(1:125) = dat.
% % cursor(1:125) = dat.cursor(1:125);
% 
% for iter_cnt = 1:length(ft)
%     %Decode + LP:
% %     if ft(i) ~=0
%          decoded_position(i) = (ft(i) - dat.decoder.mean)/dat.decoder.std;
% %     else
% %         decoded_position(i) = (ft(i-1) - dat.decoder.mean)/dat.decoder.std;
% %     end
%     earliest_ix = max([1, iter_cnt - lp_filter(i) + 1]);
%     comp_dat = [decoded_position(i);cursor(earliest_ix:iter_cnt-1)'];
%     lp_data(i) = (1/lp_filter(i))*sum(comp_dat);
%     
%     % Add assist: 
%     ideal_position = dat.targ_locs(i);
%     alpha = assist(i)/100;
%     
%     cursor(i) = nansum([alpha*ideal_position; ...
%     (1-alpha)*lp_data(i)],1);
% 
%     if cursor(i) > 10
%         cursor(i) = 10;
%     elseif cursor(i) < -10
%         cursor(i) = -10;
%     end
% 
% end






