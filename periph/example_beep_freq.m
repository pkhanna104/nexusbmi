function example_beep_freq(time_sec)

beep = wavread('beep-01a.wav');
handles.beep_ok = 0;
iters = time_sec/.4;

for it = 1:iters
    if mod(handles.beep_ok,5) == 0
        if rand(1) > .25
            soundsc(beep,140000)
            handles.beep_ok = handles.beep_ok + 1;
            
        end
    else
        handles.beep_ok = handles.beep_ok + 1;
    end
        
    %handles = run_task(handles);
    pause(.4)
end
