classdef target_task < handle
    
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
        target_generator = rand(1000,1);
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
        
    end
    
    methods
        function obj = target_task(time)
            obj.state_name_array = {'wait','target','hold','reward'};
            obj.FSM = {
                {'wait','target', @obj.start_target};
                {'target','hold', @obj.enter_target};
                {'hold','target', @obj.leave_early};
                {'hold','reward', @obj.end_hold};
                {'reward','wait', @obj.ITI_end};
                };
            obj.state_ref = { {1}; {2}; {3, 4}; {5}};
            obj.hold_time_mean = time(1);
            obj.hold_time_std =time(2);
            obj.state = 'wait';
            obj.state_ind = 1;
            obj.loop_time = .4; %loop time
            obj.ts = 0;
            obj.ITI  = .1;
            obj.rew_flag = 0;
            obj.rew_cnt = 0;
            obj.point_counter = 0;
            obj.target_generator = obj.four_targ_gen(100);
            obj.ard = NaN;
            obj.acc_dat = [0 0 0];
            obj.sub_cycle = 0;
            obj.task_fs = 20;
            obj.sub_loop_time = 1/obj.task_fs;
            obj.mod_check_neural = obj.loop_time / (1/obj.task_fs);
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
                
                if obj.target_y_pos ~= handles.window.target_pos(2)
                    handles.window.target_pos(2) = obj.target_y_pos;
                end
                
            end
            
            %Update Accel?
            try
                if isnan(obj.ard)
                end
            catch
                obj.acc_dat = [obj.ard.analogRead(0), obj.ard.analogRead(1), obj.ard.analogRead(3)];
            end
            obj.sub_cycle = obj.sub_cycle + 1;
            obj.sub_cycle_abs_time = toc(handles.tic);
            obj.tap_bool = 0;
            
        end
        
        
        function tf = start_target(obj, handles)
            obj.ts = 0 ;
            obj.hold = obj.hold_time_mean + obj.hold_time_std*randn(1,1);
            obj.target_y_pos = obj.target_generator(1);
            obj.target_generator = obj.target_generator(2:end);
            tf = 1;
        end
        
        function tf = enter_target(obj, handles)
            d = abs(handles.window.cursor_pos(2) - obj.target_y_pos);
            if d < handles.window.target_radius
                tf = 1;
            else
                tf = 0;
            end
        end
        
        function tf = leave_early(obj, handles)
            d = abs(handles.window.cursor_pos(2) - obj.target_y_pos);
            if (obj.ts < obj.hold) && (d > handles.window.target_radius)
                tf = 1;
                obj.ts = 0;
            else
                tf = 0;
            end
        end
        
        function tf = end_hold(obj, handles)
            if obj.ts > obj.hold
                tf = 1;
                obj.rew_flag = 1;
                obj.rew_cnt = obj.rew_cnt+1;
                obj.point_counter = obj.rew_cnt;
                disp('REWARD!')
            else
                tf = 0;
            end
        end
        
        function tf = ITI_end(obj, handles)
            if obj.ts > obj.ITI
                tf = 1;
                obj.rew_flag = 0;
            else
                tf = 0;
            end
        end
        
        function targ_y_pos = four_targ_gen(obj, n_targets)
            block = 3;
            
            y = [-6 -2 2 6]';
            Y = repmat(y, [block 1]);
            
            n_reps = round(n_targets/(4*block));
            
            targ_y_pos = [];
            
            for i = 1:n_reps
                idx_shuff = randperm(block*4);
                targ_y_pos = [targ_y_pos; Y(idx_shuff)];
            end
        end
        
        
    end
end