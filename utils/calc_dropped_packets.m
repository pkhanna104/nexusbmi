function dropped_packets_per_min = calc_dropped_packets(dat,...
        session_length)

    t_m1 = dat.rawdata_timeseries_m1(1:dat.iter_cnt,:);
    t_stn = dat.rawdata_timeseries_stn(1:dat.iter_cnt,:);

    if sum(sum(t_m1, 2)) ~= 0
        ix = find(sum(t_m1, 2)==0);
        dropped_packets_per_min= length(ix) / session_length;
    elseif sum(sum(t_m1, 2)) ~= 0
        ix = find(sum(t_m1, 2)==0);
        dropped_packets_per_min= length(ix) / session_length;
    else
        dropped_packets_per_min = -1;
       
    end
