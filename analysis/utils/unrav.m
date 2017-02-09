function Y = unrav(X)
% X is a m x n vector;
Y = reshape(X, [prod(size(X)), 1]);
end