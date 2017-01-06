classdef finger_tapping_task < handle
    
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
        tapping_time;
        center_pause_time;
        target_generator = rand(1000,1);
        rew_cnt;
        point_counter;
        rew_flag;
        target_y_pos;
        tap_cnt;
        tap_val;
        total_taps;
        last_tap;
        sub_cycle;
        task_fs;
        mod_check_neural;
        sub_loop_time;
        sub_cycle_abs_time;
        tap_time;
        tap_bool; %For compatibiility w/ other tasks
        mod_check_neural_cnt;
        ard;
    end
    
    methods
        function obj = finger_tapping_task(time)
            obj.state_name_array = {'wait','target','hold','tapping','reward'};
            obj.FSM = {
                       {'wait','target', @obj.start_target}; 
                       {'target','tapping', @obj.enter_target};
                       {'target','wait', @obj.nf_timeout};
                       {'hold','target', @obj.leave_early};
                       {'hold','tapping', @obj.end_hold};
                       {'tapping','reward', @obj.end_tapping};
                       {'reward','wait', @obj.ITI_end};
                       };
            obj.state_ref = { {1}; {2, 3}; {4, 5}; {6};{7}};
            obj.hold_time_mean = time(1);
            obj.hold_time_std =time(2);
            obj.hold = 0;
            obj.state = 'wait';            
            obj.state_ind = 1;
            obj.loop_time = .4; %loop time
            obj.ts = 0;
            obj.ITI  = .1;
            obj.rew_flag = 0;
            obj.rew_cnt = 0;
            obj.point_counter = 0;
            obj.target_generator = obj.three_targ_co_gen(100);
            obj.sub_cycle = 0;
            obj.task_fs = 20;
            obj.sub_loop_time = 1/obj.task_fs;
            obj.tap_bool = nan;
            obj.ard = nan;
            
            %How often to check for neural 
            obj.mod_check_neural_cnt = tic; %(obj.loop_time / (1/obj.task_fs))-2;
            
            % [Rx, Ry, Rz; Lx, Ly, Lz];
            obj.sub_cycle_abs_time = 0;
            obj.target_y_pos = -100;
            obj.tapping_time = 6;
            obj.center_pause_time = 1;            
            
        end
        
        function handles = cycle(obj, handles)
            %Main cycle of task:
                %Note that the first 'if' loop only happens when we check for 
                %neural data, else only the arduino stuff gets updated
                
            %Run through FSM every 0.4 sec: 
            %if toc(obj.mod_check_neural_cnt) > obj.loop_time
            %if mod(obj.sub_cycle , obj.mod_check_neural)==0
            if handles.neural_data_avail
                disp(strcat('in task, cyle: ', num2str(obj.sub_cycle), ' state: ', obj.state))
                disp(strcat(' hodl tm: ', num2str(obj.hold)))
                disp(strcat(' obj.ts ', num2str(obj.ts)))
                
                check_func = obj.state_ref{obj.state_ind};
                %Run through all necessary fcns to check for state changes 
                for i = 1:size(check_func,2)
                    func = obj.FSM{check_func{1,i}}{3};
                    tf = func(handles);
                    
                    %Update State
                    if tf 
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
            
            %Update Tapping 
%               [d1, ax, ay, az, axL, azL] = obj.ard.read();
%               obj.acc_dat = [ax, ay, az; axL, 0, azL];
%               obj.touch_dat = d1;
%               obj.sub_cycle = obj.sub_cycle + 1;
%               obj.sub_cycle_abs_time = toc(handles.tic);
        end
        
        function tf = start_target(obj, handles)
            obj.tap_cnt = 0;
            obj.ts = 0 ;
            obj.hold = obj.hold_time_mean + obj.hold_time_std*randn(1,1);
            obj.target_y_pos = obj.target_generator(1);
            obj.target_generator = obj.target_generator(2:end);
            set(handles.window.tap_text,'String', '\fontsize{18} \color{black} ');
            tf = 1;
        end
 
        function tf = enter_target(obj, handles)
            d = abs(handles.window.cursor_pos(2) - obj.target_y_pos);
            if d < handles.window.target_radius
                tf = 1;
                
                %Only for periph targets
                if abs(obj.target_y_pos)>0
                    set(handles.window.target, 'MarkerFaceColor', 'c');
                    set(handles.window.tap_text,'String', handles.tap_on_str);
                    obj.tap_time = obj.tapping_time;
                else
                    obj.tap_time = obj.center_pause_time;
                end

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
        
        function tf = nf_timeout(obj, handles)
            if obj.ts > handles.timeoutTime
                tf = 1;
            else
                tf = 0;
            end
            
        end
        
        function tf = end_hold(obj, handles)
            if obj.ts > obj.hold
                tf = 1;
                %Only for periph targets
                if abs(obj.target_y_pos)>0
                    set(handles.window.target, 'MarkerFaceColor', 'c');
                    set(handles.window.tap_text,'String', handles.tap_on_str);
                    obj.tap_time = obj.tapping_time;
                else
                    obj.tap_time = obj.center_pause_time;
                end
            else
                tf = 0;
            end
        end
        
        function tf = end_tapping(obj, handles)
            if obj.ts > obj.tap_time
                tf = 1;
            else
                tf = 0;
            end
            
            if tf
                obj.rew_flag = 1;
                obj.rew_cnt = obj.rew_cnt+1;
                obj.point_counter = obj.rew_cnt;
                disp('Score !')
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
        
        function targ_y_pos = three_targ_co_gen(obj, n_targets)
            block = 2;
            y = [-6, 6]';
            Y = repmat(y, [block, 1]);
            n_reps = round(n_targets/(2*block));
            
            targ_y_pos = [];
            for i = 1:n_reps
                idx_shuff = randperm(block*2);
                for j = 1:length(idx_shuff)
                    targ_y_pos = [targ_y_pos; Y(idx_shuff(j)); 0];
                end
            end
        end
              
    end
end