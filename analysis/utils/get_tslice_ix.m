function [tsl_start, tsl_stop] = get_tslice_ix(dat, tsl, tslice_opt, trim_n_targs)
%Tslice parse:
    
    if strcmp(tslice_opt, 'sec')
        tsl_start = find(cumsum(dat.loop_time) > tsl(1));
        if length(tsl_start) > 0
            tsl_start = tsl_start(1);
        else
            msgID = 'MYFUN:BadIndex';
            msg = 'Unable to use tslice start value -- too big.';
            baseException = MException(msgID,msg);
        end
        
        if tsl(2) > -1 
            tsl_stop = find(cumsum(dat.loop_time) < tsl(2));
            if length(tsl_stop) > 0
                tsl_stop = tsl_stop(end);
            else
                msgID = 'MYFUN:BadIndex';
                msg = 'Unable to use tslice stop value -- too low.';
                baseException = MException(msgID,msg);
            end
        else
            tsl_stop = length(dat.loop_time);
        end
        
    elseif strcmp(tslice_opt, 'targ_num')
        rew = [];
        for i = 1:length(dat.state)
            if strcmp('reward',dat.state{i})
                rew = [rew i];
            end
        end
        
        tsl_start = rew(tsl(1));
        if tsl(2) > -1 
            tsl_stop = rew(tsl(2));
        else
            tsl_stop = length(dat.loop_time);
        end
        
    elseif strcmp(tslice_opt, 'ix')
        tsl_start = tsl(1);
        if tsl(2) > -1 
            tsl_stop = tsl(2);
        else
            try
                tsl_stop = length(dat.loop_time);
            catch
                tsl_stop = dat.iter_cnt - 1;
            end
        end
    end
        
    if trim_n_targs > 0
        rew = [];
        for i = 1:length(dat.state)
            if strcmp('reward',dat.state{i})
                rew = [rew i];
            end
        end
        
        tsl_stop = min([tsl_stop rew(end-trim_n_targs)]);
    end