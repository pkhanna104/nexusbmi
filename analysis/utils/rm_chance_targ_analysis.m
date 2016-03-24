%Fit Separate Model for Data: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Model 1 -- single Gaussian: %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and concat all data: 
targs = [];
p1 = load('time2targ_050815gh.mat');
p2 = load('time2targ_092815i.mat');
p3 = load('time2targ_103015dfjk.mat');

loop = {'p1', 'p2', 'p3'};
for l=1:length(loop)
    p = eval(loop{l});
    
    for i=1:length(p.time2targ_save)
        if ~isempty(p.time2targ_save{i})
            targs = [targs p.time2targ_save{i}];
        end
    end
end

%Fit Gaussian: 
phat = mle(targs,'distribution','normal');

%Predict Log-Likelihood:
prob = normpdf(targs, phat(1), phat(2));
LL = sum(log10(prob));
AIC1 = (2*2) - (2*LL)
BIC1 = (-2*LL) + 2*log10(length(targs));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Model 2 -- two Gaussians: %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model 2 -- two Gaussians: 
% Load and concat all data: 
targ_ch = [];
targ_act = [];

ch_targ = {[-2], [-2 2], [2 6]};

for l=1:length(loop)
    p = eval(loop{l});
    ch = ch_targ{l};
    
    for i=1:length(p.time2targ_save)
        if ~isempty(p.time2targ_save{i})
            if ~isempty(find(i-7 == ch))
                disp(strcat(num2str(i-7), '_'))
                disp(ch)
                targ_ch = [targ_ch p.time2targ_save{i}];
            else
                targ_act = [targ_act p.time2targ_save{i}];
            end
        end
    end
end

%Fit Gaussian: 
phat_ch = mle(targ_ch,'distribution','normal');
phat_act = mle(targ_act,'distribution','normal');

%Predict Log-Likelihood:
prob_ch = normpdf(targ_ch, phat_ch(1), phat_ch(2));
prob_act = normpdf(targ_act, phat_act(1), phat_act(2));

LL2 = sum(log10(prob_ch)) + sum(log10(prob_act));
AIC2 = (2*4) - (2*LL2);
BIC2 = (-2*LL2) + 4*log10(length(targ_act)+length(targ_ch))


