classdef target_touch_task < handle
    
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
        tap_cnt;
        tap_val;
        total_taps;
        ard;
        tap_bool;
        rtap_bool;
        last_tap;
        sub_cycle;
        task_fs;
        mod_check_neural;
        sub_loop_time;
        sub_cycle_abs_time;
        acc_dat;
        touch_sens;
    end
    
    methods
        function obj = target_touch_task(time)
            obj.state_name_array = {'wait','target','hold','tapping','reward'};
            obj.FSM = {
                       {'wait','target', @obj.start_target}; 
                       {'target','hold', @obj.enter_target};
                       {'target','wait', @obj.timeout_or_stop_hold};
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
            %obj.target_generator = obj.four_targ_gen(100);
            obj.target_generator = obj.three_targ_co_gen(100);
            obj.tap_cnt = 0;
            obj.total_taps = 3;
            obj.last_tap = 'left';
            obj.tap_bool = 0;
            obj.rtap_bool = 0;
            obj.touch_sens = [0, 0];
            obj.ard = NaN;
            obj.sub_cycle = 0;
            obj.task_fs = 10;
            obj.sub_loop_time = 1/obj.task_fs;
            obj.mod_check_neural = (obj.loop_time / (1/obj.task_fs))-2;
            obj.acc_dat = [0 0 0];
            obj.sub_cycle_abs_time = 0;
            obj.target_y_pos = -100;
            
        end
        
        function handles = cycle(obj, handles)

            %Run through FSM every 0.4 sec: 
            if mod(obj.sub_cycle , obj.mod_check_neural)==0
                disp(strcat('in task: ', num2str(obj.sub_cycle), ' state: ', obj.state))
                disp(strcat(' bools: tap_bool: ', num2str(obj.tap_bool)))
                disp(strcat(' bools: R tap_bool: ', num2str(obj.rtap_bool)))
                disp(strcat(' bool flag: ', obj.last_tap))
                disp(strcat(' bool cnt: ',num2str(obj.tap_cnt)))
                disp(strcat(' hodl tm: ', num2str(obj.hold)))
                disp(strcat(' obj.ts ', num2str(obj.ts)))
                
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
            
            %Update Tapping? 
            [d1, d2, ax, ay, az] = obj.ard.read();
            obj.acc_dat = [ax, ay, az];
            obj.tap_bool = d1;
            obj.rtap_bool = d2;
            obj.touch_sens = [d1, d2];
            obj.sub_cycle = obj.sub_cycle + 1;
            obj.sub_cycle_abs_time = toc(handles.tic);
        end
        
        function tf = start_target(obj, handles)
            if obj.tap_bool
                obj.tap_cnt = 0;
                obj.ts = 0 ;
                obj.hold = obj.hold_time_mean + obj.hold_time_std*randn(1,1);
                obj.target_y_pos = obj.target_generator(1);
                obj.target_generator = obj.target_generator(2:end);
                set(handles.window.tap_text,'String', '\fontsize{18} \color{black} ');
                tf = 1;
            else
                set(handles.window.tap_text,'String', '\fontsize{18} \color{red} Hold Left');
                tf = 0;
            end
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
        
        function tf = timeout_or_stop_hold(obj, handles)
            if obj.ts > handles.timeoutTime
                tf1 = 1;
            else
                tf1 = 0;
            end
            
            if obj.tap_bool == 0
                tf2 = 1;
            else
                tf2 = 0;
            end      
            
            if or(tf1, tf2)
                tf = 1;
                set(handles.window.tap_text,'String', '\fontsize{18} \color{red} Hold Left');
            else
                tf = 0;
            end
        end
        
        function tf = stop_left_hold(obj, handles)
            if obj.tap_bool == 0
                tf = 1;
            else
                tf = 0;
            end
        end
        function tf = end_hold(obj, handles)
            if obj.ts > obj.hold
                tf = 1;
                if abs(obj.target_y_pos)>0
                    set(handles.window.target, 'MarkerFaceColor', 'c');
                    set(handles.window.tap_text,'String', handles.tap_on_str);
                end
            else
                tf = 0;
            end
        end
        
        function tf = end_tapping(obj, handles)
            tf = 0;
            if abs(obj.target_y_pos) > 0
                %Begin with obj.tap_bool;
                if strcmp(obj.last_tap, 'right')
                    if obj.tap_bool
                        obj.last_tap = 'left';
                        obj.tap_cnt = obj.tap_cnt + 1;
                        updated_str = [handles.tap_on_str(1:end-1) ': ' num2str(obj.total_taps - obj.tap_cnt)];
                        set(handles.window.tap_text,'String', updated_str);
                    end
                elseif strcmp(obj.last_tap, 'left')
                    if obj.rtap_bool
                        obj.last_tap = 'right';
                    end
                end

                if obj.tap_cnt >= obj.total_taps
                    tf = 1;
                    obj.tap_cnt = 0;
                    set(handles.window.tap_text,'String', handles.tap_off_str);
                end
            else
                tf = 1;
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