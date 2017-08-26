function [W,loss,yhat,xi] = svmmulti(X,y,beta,kernel)
% Computes a soft margin classifier
% X is has each row a sample
% Assuming identity kernel, K = X'*X if kernel not given
% assumes y a col vector in {-1,1}
% alpha = 1/(2beta) where beta is the slack parameter
%
% Optimizes:
%   min_w 1/n \sum_i hinge_loss(xi,yi;w) s.t. ||w||_2 <= C
%
%   Uses dual formulation (with slacks) to optimize primal:
%       min_w,eps beta/2 ||w||^2 + eps^T e   s.t. eps >= 0, yi(w^T
%       phi(xi)+b) >= 1-eps_i
% 
%   Dual:
%       max_lambda lambda^T e - 1/(2 beta) < K haddamard lambda
%       lambda^T, yy^T>     s.t. 0 <= lambda <= 1, lambda^T y = 0
%

% If y not 1-dim, then calls svm multiclass assuming X has row samples
% and Y is a n x k matrix
if (min(size(y)) ~= 1)
    kerneloption.matrix = X*X';
    [xsup,W] = svmmulticlass(X,y,-1,-1,'numerical',kerneloption);
    loss = 0; yhat = 0; xi = 0;
    return;
end

X = X';
y = y';
if (nargin < 3 || beta == 0)
    beta = 0.1;
end
if (nargin < 4 || kernel == [])
    K = X' * X;
else
    K = kernel(X', X');
end

alpha = 1/(2*beta);
t = size(K,1);
H = K .* (y'*y) / alpha;
f = -ones(t,1);

% quadprog
lb = zeros(t,1);
ub = ones(t,1);
[mu,qploss,flag] = quadprog(H,f,[],[],[],[],lb,ub, [],...
                    optimset('Display', 'off', 'TolFun', 1e-4, 'TolX',1e-4));

loss = -qploss;
F = K*(mu.*y')/alpha;
yhat = sign(F);
xi = max(1 - y'.*F, 0);
W=X*(y'.*mu);
W = W';

