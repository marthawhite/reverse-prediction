function [X,Y,U] = genRevExp(t,n,k,sigma,epsilon)
% GENREVEXP generates data X,Y and U

if nargin < 5
    epsilon = 1e-5;
end

% Generate Y and U between 0 and 1
Y = rand(t,k);
U = rand(k,n);
%Y = randn(t,k);
%Y = (Y+abs(min(min(Y)))+epsilon);
%U = randn(k,n);
%U = U+abs(min(min(U)))+epsilon;

X = log(Y*U) + sigma.*randn(t,n);

X = randn(t,n);
W = randn(n,k);
Y = exp(X*W);
X = X + sigma*randn(t,n);

end
