function regress_move_times(rch_abs_time, targ_inds, ix_bound, targ_start_abs_time,local_reg, global_reg, ignore_before_secs)
cmap4 = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
%cmap3 = {[70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

ix_start = 0;
unique_tg = [-6 -2 2 6];
figure(99);

if local_reg
    for blk = 1:length(ix_bound)
        if ix_start < ignore_before_secs
            ix_start = ignore_before_secs;
        end
        ix_tg = find(and(targ_start_abs_time>=ix_start, targ_start_abs_time<=ix_bound(blk)));
        if ~isempty(ix_tg)
            [p, slp, int] = reg_tg(rch_abs_time(ix_tg), targ_inds(ix_tg), targ_start_abs_time(ix_tg));
            figure(99);
            for ii = 1:length(unique_tg)
                tg_ix = find(targ_inds(ix_tg)==unique_tg(ii));
                if ~isempty(tg_ix)
                    xi = targ_start_abs_time(ix_tg(1)):targ_start_abs_time(ix_tg(end));
                    yi = slp{ii}*xi + int{ii};
                    subplot(2,2,ii)
                    hold on;
                    plot(xi/60, yi, '--', 'color', cmap4{ii},'linewidth',2)
                end
            end
        end
        ix_start = ix_bound(blk);
    end
end
if global_reg
    ix_glob = find(targ_start_abs_time>ignore_before_secs);
    [p, slp, int] = reg_tg(rch_abs_time(ix_glob), targ_inds(ix_glob), targ_start_abs_time(ix_glob));
    for ii = 1:length(unique_tg)
        tg_ix = find(targ_inds(ix_glob)==unique_tg(ii));
        if ~isempty(tg_ix)
            xi = 0:targ_start_abs_time(end);
            yi = slp{ii}*xi + int{ii};
            subplot(2,2,ii)
            plot(xi/60, yi, '-', 'color', cmap4{ii}, 'linewidth', 2)
            xlim([ignore_before_secs/60,1.05*targ_start_abs_time(end)/60])
            ylim([0 1.2*max(rch_abs_time(ix_glob(tg_ix)))])
            title(strcat('Targ: ',num2str(unique_tg(ii)), ' , Slope P-value: ',num2str(p{ii})))
        end
    end
end


    function [p, slp, int] = reg_tg(rch, tg_inds, tg_start)
        for i=1:length(unique_tg)
            ix = find(tg_inds==unique_tg(i));
            if ~isempty(ix)
                
                X = tg_start(ix);
                Y = rch(ix);
                
                lm = fitlm(X,Y,'linear');
                slp{i} = lm.Coefficients.Estimate(2);
                int{i} = lm.Coefficients.Estimate(1);
                
                p{i} = lm.Coefficients.pValue(1);
            end
        end
    end
end
