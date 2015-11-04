function [rch_time, targ_inds, abs_time, coeffs, abs_tm_lim] = calc_movement_time(block, day, sec_cutoff)

    cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
    figure(99); hold all;
    
    [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state, dat] = parse_dat(block, day);

    if ~isnan(sec_cutoff)
        abs_t_zerod = abs_t - abs_t(1);
        rew_cutoff_ix = find(abs_t_zerod(rew_inds)<= sec_cutoff);
    else
        rew_cutoff_ix = 1:length(rew_inds);
    end
    
    
    targ_inds = targ(rew_inds(rew_cutoff_ix));
    targ_unique = unique(targ_inds);
    rch_time = zeros(length(targ_inds),1);
    abs_time = zeros(length(targ_inds),1);
    rew_time = zeros(length(targ_inds),1);
    coeffs = zeros(4,2);
    
    curs_cell = {};
    
    %Calculate time to movement
    H = [];
    P = [];
    leg_lab = {};

    for i=1:length(targ_unique)
        tmp = find(targ_inds==targ_unique(i));
        targ_rew_ix = rew_inds(tmp);
        rch_ix = [];
        curs_targ = zeros(length(targ_rew_ix), 5);
        rew_time = [];
        %Step backward from rew_ind to get time of 'wait' 
        for t = 1:length(targ_rew_ix)
            srch = 1;
            ix = 0;
            while srch
                if strcmp(state{targ_rew_ix(t)-ix}, 'wait')
                    srch = 0;
                    rch = ix;
                else
                    ix = ix + 1;
                end
            end
            ting = find(rew_inds==targ_rew_ix(t));
            rch_time(ting) = rch;
            abs_time(ting) = dat.abs_time(targ_rew_ix(t))-dat.abs_time(1);
            rew_time = [rew_time dat.abs_time(targ_rew_ix(t))-dat.abs_time(1)];
            rch_ix = [rch_ix rch];
            try
                curs_targ(t,:) = curs(targ_rew_ix(t)-4:targ_rew_ix(t));
            catch
            end
        end
        curs_cell{i} = curs_targ;
        
        figure(99)
        h1 = plot(rew_time, rch_ix, 'o', 'color',cmap{i});
        set(h1,'MarkerEdgeColor','none','MarkerFaceColor',cmap{i})
        ix_bd = find(rch_ix<=160);
        x = rew_time(ix_bd);
        y = rch_ix(ix_bd)*.4;
        
        tbl = table(x', y', 'VariableNames', {'x','y'});
        mdl = fitlm(tbl,'y~x');
        coeff=mdl.Coefficients.Estimate;
        hold on;
        coeffs(i,:) = coeff(1:2);
        abs_tm_lim(i,:) = [x(1) x(end)];
        h=plot(x, coeff(1)+(coeff(2)*x),'-','color',cmap{i});
        H = [H h];
        disp(strcat('Slope P value: ', num2str(i), ' ,',num2str(mdl.Coefficients.pValue(2))));
        leg_lab{i}=strcat('Target ', num2str(i), ': p-val slope: ', num2str(mdl.Coefficients.pValue(2)));
        xlabel('Time(sec)','fontsize',20)
        ylabel('Target Acquisition Times (sec)','fontsize',20)
        title(strcat(day, block))
        
        figure(98); hold all;
        plot(1:5, mean(curs_cell{i}, 1), '.-','color', cmap{i})
        xlabel('Time (.4 sec steps)','fontsize',20)
        ylabel('Cursor','fontsize',20)
        title(strcat(day, block),'fontsize',20)
    end
    tm = {'Target: -6','Target: -2', 'Target: 2','Target: 6'};
    legend(fliplr(H), fliplr(leg_lab),'fontsize',20)
    
end

