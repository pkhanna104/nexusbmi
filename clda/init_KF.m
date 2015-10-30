function decoder = init_KF(feats, decoder, targ_pos)

%Estimate X_1:T from Y_1:T -- 
%First assume no Noise (W = 0) in state space
[~, nc] = size(feats);
if nc==1
    feats = feats';
end

%Normalize features:
sqrt_neur = sqrt(feats);
neur = sqrt_neur - mean(sqrt_neur);

%Stupid method: 
if length(targ_pos)==0
    targ_pos = zeros(length(neur),1);
    low_cut = 0;
    targs = [-6 -2 2 6];
    for ii = 1:4
        cutoff = prctile(neur, ii*25);
        ix = find(and(neur>= low_cut, neur<cutoff));
        targ_pos(ix) = targs(ii);
    end
end
%In neural space: 
% Y_targ_low = prctile(neur,10);
% Y_targ_hi = prctile(neur, 90);
% 
% %Estimate C matrix:
% m = (6--6)/(Y_targ_hi - Y_targ_low);
% b = 6 - (m*Y_targ_hi);
% 
% C = [1/m -b/m];
% Y = [neur ];
% %X = zeros(size(Y));
% X = m*Y + b;
% X = [X; ones(1, size(X,2))];
%X(1:end-1,:) = (Y-C(:,end))/C(:,1:end-1);

Y = [neur];

%Add a little noise to X: 
eps = (randn(1, length(targ_pos)) - 0.5)*10^-1;
X = [targ_pos'+eps; ones(1, length(targ_pos))];

%Estimate C: 
C = (inv(X*X')*(X*Y'))';

%Estimate A, W: 
A = (X(:,2:end)*X(:,1:end-1)')*inv((X(:,1:end-1)*X(:,1:end-1)'));
A(end,end) = 1; %Unnecessary

W = 1/(length(feats)-1)*((X(:,2:end)*X(:,2:end)') - A*(X(:,1:end-1)*X(:,2:end)'));
W(end,end) = 0;

%Estimate Q (should be zero):
Q = 1/length(feats)*((Y*Y') - C*(X*Y'));

decoder.A = A;
decoder.W = W;
decoder.C = C;
decoder.Q = Q;
decoder.mn_sqrt_neur = mean(sqrt_neur);

% For potential RML 
decoder.R_init = 1/size(X,2)*(X*X');
