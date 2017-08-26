function [X,Y,U] = genRevLog(t,n,k,sigma,epsilon)
% GENREVLOG generates data X,Y and U

if nargin < 5
    epsilon = 1e-5;
end

% Generate Y and U between 0 and 1
Y = rand(t,k);
U = rand(k,n);

X = exp(Y*U) + sigma.*randn(t,n);

end
