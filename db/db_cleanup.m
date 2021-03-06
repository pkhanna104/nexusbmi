function [TARG, REW, reach_time, avg, session_length] = db_cleanup(handles, dat, data_filename, only_test)

% Find database file:
session_length = dat.rawdata_abs_time(dat.iter_cnt - 1) - dat.rawdata_abs_time(1);
    
if ~only_test
    db_fname = strcat(handles.root_path, 'db\tasks2.db');
    conn = database(db_fname,[],[],'org.sqlite.JDBC',['jdbc:sqlite:' db_fname]);
    export_data = {};

    sqlquery = 'select task_entry from task_entries';
    curs = exec(conn, sqlquery);
    curs = fetch(curs);
    max_te = max(curs.Data);

    te = max_te + 1;
    export_data{1,2} = te;

    colnames = {'patient_id', 'task_entry', 'session_length', 'datafile',...
        'decoderfile', 'clda_type', 'input_signal_type', 'arduino', 'task_name',...
        'avg_assist', 'dropped_packets_per_min', 'avg_time_to_targ_low',...
        'avg_time_to_targ_midlow', 'avg_time_to_targ_midhi',...
        'avg_time_to_targ_hi','date','time'};

    % Go through db column-by-column

    % Date:
    date_str = date;
    export_data{1, 16} = date_str;

    % Time:
    c = clock;
    time_str = strcat(num2str(c(4)), ':',num2str(c(5)),'.', num2str(round(c(6))));
    export_data{1, 17} = time_str;

    % Session length:
    export_data{1, 3} = session_length;

    % Data file name: 
    export_data{1, 4} = data_filename;

    % Decoder name:
    dec_list = get(handles.decoder_list, 'String');
    dec_ix = get(handles.decoder_list, 'Value');
    decoder_filename = dec_list{dec_ix};
    export_data{1, 5} = decoder_filename;

    % CLDA type: 
    if get(handles.clda_box, 'Value')
        clda = strcat('RML: ', get(handles.clda_sec_box, 'String'));
    else
        clda = 'None';
    end
    export_data{1, 6} = clda;

    %Input signal type: 
    input_signal = handles.neural_source_name;
    export_data{1, 7} = input_signal;

    % Arduino?
    ard_bool = get(handles.ard_check, 'Value');
    if ard_bool
        ard = strcat(get(handles.arduino_comport, 'String'), ': BT: ',...
            num2str(get(handles.bt_check_box, 'Value')));
    else
        ard = 'Not Used';
    end
    export_data{1, 8} = ard;

    % Task name: 
    ix = get(handles.task_list_pulldown,'Value');
    d = get(handles.task_list_pulldown, 'String');
    task = d{ix};
    export_data{1, 9} = task;

    % Avg. assist:
    a = dat.assist_level(1:dat.iter_cnt-1);
    assist_mean = mean(a);
    export_data{1, 10} = assist_mean;

    %Dropped packets / min
    dp_per_min = calc_dropped_packets(dat, session_length);
    export_data{1, 11} = dp_per_min;
end

%Avg time 2 target (lo, lowmid, himid, hi)
TARG = dat.target;
REW = dat.reward_times{1};
try
    reach_time = [REW(1)];
catch
    reach_time = [];
end

for i=2:length(REW)
    rt = REW(i) - (REW(i-1)+4);
    reach_time = [reach_time rt];
end
reach_time = reach_time*(.4);


rt_by_targ = [0 0 0 0];
rt_by_targ_cnt = [0 0 0 0];

targs = [-6, -2, 2, 6];

for r=1:length(REW)
    t = TARG(REW(r));
    ix = find(targs==t);

    rt_by_targ(ix) = rt_by_targ(ix) + reach_time(r);
    rt_by_targ_cnt(ix) = rt_by_targ_cnt(ix) + 1;
end

avg = rt_by_targ./rt_by_targ_cnt;

if ~only_test
    export_data{1, 12} = avg(1);
    export_data{1, 13} = avg(2);
    export_data{1, 14} = avg(3);
    export_data{1, 15} = avg(4);

    datainsert(conn, 'task_entries', colnames, export_data);
    close(curs);
    close(conn);
end


    
    
    
    
    
    


 
 
