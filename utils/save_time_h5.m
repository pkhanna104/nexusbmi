function save_time_h5(handles, time)
    fname_h5 = handles.save_data_h5;
    ix = handles.iter_cnt;
    h5write(fname_h5, '/neural/timestamp',time, [1, ix], [1,1])
end