classdef movement_task < handle
    
    properties
        state_name_array;
        FSM; %Finite state machine
        hold_time_mean; % Target hold time mean
        hold_time_std; % Target hold time var
        hold; %Individual trial hold time
        ITI; %Inter trial interval
        state; %Task state
        state_ind; %Task state index
        loop_time; %
        ts; %Time in state
        state_ref; %State reference matrix
        rew_cnt;
        point_counter;
        rew_flag;
        target_y_pos;
        
        
        ard;
        sub_cycle;
        task_fs;
        sub_loop_time;
        mod_check_neural;
        sub_cycle_abs_time;
        acc_dat;
        tap_bool;
        
        beep;
        beep_bool;
    end
    
    methods
        function obj = movement_task(time)
            obj.state_name_array = {'wait','hold','cue'};
            obj.FSM = {
                       {'wait','hold', @obj.start_hold}; 
                       {'hold','cue', @obj.cue_on};
                       {'cue','wait', @obj.ITI_end};
                       };
            obj.state_ref = { {1}; {2}; {3}};
            obj.hold_time_mean = time(1);
            obj.hold_time_std =time(2);
            obj.state = 'wait';
            obj.state_ind = 1;
            obj.loop_time = .4; %loop time
            obj.ts = 0;
            obj.ITI  = 5;
            obj.rew_flag = 0;
            obj.rew_cnt = 0;
            obj.point_counter = 0;
            obj.ard = NaN;
            obj.acc_dat = [0 0 0];
            obj.sub_cycle = 0;
            obj.task_fs = 20;
            obj.sub_loop_time = 1/obj.task_fs;
            obj.target_y_pos = nan;
            obj.beep = wavread('beep-01a.wav');
            obj.tap_bool = 0;
            obj.mod_check_neural = (obj.loop_time / (1/obj.task_fs))-2;
            obj.sub_cycle_abs_time = 0;
            obj.beep_bool = 0;
        end
        
        function handles = cycle(obj, handles)
            if mod(obj.sub_cycle , obj.mod_check_neural)==0
            
                %Run through FSM
                check_func = obj.state_ref{obj.state_ind};
                for i = 1:size(check_func,2)
                    func = obj.FSM{check_func{1,i}}{3};
                    tf = func(handles);

                    if tf %Update State
                        obj.state = obj.FSM{check_func{1,i}}(2);
                        obj.state_ind = find(ismember(obj.state_name_array, obj.state));
                        obj.ts = 0;
                    else
                        obj.ts = obj.ts + obj.loop_time;
                    end
                end
               
            end
            
            %Update Accel
            obj.tap_bool = digitalRead(obj.ard,8);
            obj.acc_dat = [obj.ard.analogRead(0), obj.ard.analogRead(1), obj.ard.analogRead(3)];
            obj.sub_cycle = obj.sub_cycle + 1;
            obj.sub_cycle_abs_time = toc(handles.tic);
            
        end
        
        function tf = start_hold(obj, handles)
            obj.ts = 0;
            obj.hold = obj.hold_time_mean + obj.hold_time_std*randn(1,1);
            tf = 1;
        end
 
        function tf = cue_on(obj, handles)
            if obj.hold < obj.ts
                tf = 1;
                soundsc(obj.beep,140000)
                obj.beep_bool = 1;
            else
                tf = 0;
            end
        end
        
        function tf = ITI_end(obj, handles)
            obj.beep_bool = 0;
            if obj.ts > obj.ITI
                tf = 1;
                obj.rew_flag = 0;
            else
                tf = 0;
            end
        end
        
    end
end