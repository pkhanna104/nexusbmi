function concat_reaching(day, blocks, cutoff_arr)
R = [];
T = [];
A = [0];
blk = [];
C = {};
for b = 1:length(blocks)
    [rch_time, targ_inds, abs_time, coeffs, abs_tm_lim] = calc_movement_time(blocks(b), day, cutoff_arr(b));
    R = [R rch_time'];
    T = [T targ_inds'];
    C{b,3} = A(end);
    A = [A abs_time'+A(end)];
    blk = [blk A(end)];
    C{b,1} = coeffs;
    C{b,2} = abs_tm_lim; 
end
A = A(2:end);
cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};
figure(77); hold all;

t_val = sort(unique(T));

for t = 1:length(t_val)
    ix = find(T==t_val(t));
    figure(77);
    h1 = plot(A(ix), R(ix), '.','color',cmap{t});
    %set(h1,'MarkerEdgeColor','none','MarkerFaceColor',cmap{t})
    for b=1:length(blk)
        coef = C{b,1}(t,:);
        y = coef(1)+coef(2)*C{b,2}(t,:);
        plot(C{b,3}+C{b,2}(t,:), y, '-', 'color', cmap{t});
    end
end

for b = 1:length(blk)
    figure(77);
    plot([blk(b), blk(b)], [0, 200], 'k--')
end
    