function plot_arduino_hr(hr, trial_outcome)

ix = [];
ib = {};
trl = [];
for t = 1:length(trial_outcome)
    try
        hr0 = hr.(strcat('trl_', num2str(t)));
        ibis = get_IBIs_SRS(hr0, 50);
        ix = [ix trial_outcome(t, end)];
        ib{t} = ibis;
        trl = [trl t];
    catch
        fprintf('skipping %d\n', t);
    end 
end

ib_array = [];
ib_value = [];
for i = 1:length(ix)
    n = length(ib{trl(i)});
    ib_value = [ib_value ib{trl(i)}];
    ib_array = [ib_array zeros(1, n)+ix(i)];
end
    
lm = fitlm(ib_array,ib_value,'linear')
