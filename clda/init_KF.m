function decoder = init_KF(feats, decoder)

%Estimate X_1:T from Y_1:T
%First assume no Noise (W = 0) in state space
[~, nc] = size(feats);
if nc==1
    feats = feats';
end
neur = sqrt(feats);

Y_targ_low = prctile(neur,10);
Y_targ_hi = prctile(neur, 90);

%Estimate C matrix:
m = (Y_targ_hi - Y_targ_low)/(6--6);
b = (Y_targ_hi - (m*6));

C = [m b;];
Y = [feats ];
X = zeros(size(Y));
X = [X; ones(1, size(X,2))];
X(1:end-1,:) = (Y-C(:,end))/C(:,1:end-1);

%Estimate A, W: 
A = (X(:,2:end)*X(:,1:end-1)')*inv((X(:,1:end-1)*X(:,1:end-1)'));
W = 1/(length(feats)-1)*((X(:,2:end)*X(:,2:end)') - A*(X(:,1:end-1)*X(:,2:end)'));

%Estimate Q (should be zero):
Q = 1/length(feats)*((Y*Y') - C*(X*Y'));

decoder.A = A;
decoder.W = W;
decoder.C = C;
decoder.Q = Q;
