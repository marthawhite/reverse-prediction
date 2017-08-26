function [W,U,Y,Xhat] = recoverForwardModelSemi(X,f,f_inv,CA,Lfor,tl,kernel)
% CA is the clustering algorithm
% Lfor is the loss function
% if kernel provided, then learn forward model on kernel

t = size(X,1);
n = size(X,2);

% Step 1: Compute Y and M
[Y,M] = CA();
k = size(Y,2);
%Y = roundY(Y);
%[match, P] = align(Ytrain,Y);
%Y = roundY(Y*P);

% Step 2: Get reverse model U
U = f(M);
Xhat = f_inv(Y*U);

% Step 3: Solve for forward model
% Use regularization
% IGNORE FORWWARD MODEL FOR NOW
W = [];
%beta = 1e-5;
%if exist('kernel','var') && ~isempty(kernel)
%    K = kernel(X,X);
%    Wsize = [t,k];
%    [W, obj] = fmin_LBFGS(@vecloss_kernel,randn(Wsize(1)*Wsize(2),1));
%else    
%    Wsize = [n,k];
%    [W, obj] = fmin_LBFGS(@vecloss,randn(Wsize(1)*Wsize(2),1));
%end
%W = unvec(W,k);

% return Y only for unlabeled data
Y = roundY(Y);
Y = Y((tl+1):end,:);

function [f,g] = vecloss(W)
    denom = t;
    [f1,g1] = Lfor(X,unvec(W,k),Y);
    f2 = beta*(W'*W)/(2*denom);
    g2 = beta*W/denom;
    f = f1+f2;
    g = g1(:) + g2;
end

function [f,g] = vecloss_kernel(W)
    Wmat = unvec(W,k);
    denom = t;
    [f1,g1] = Lfor(K,Wmat,Y);
    f2 = beta*trace(Wmat*Wmat'*K)/(2*denom);
    g2 = beta*K*Wmat/denom;
    f = f1+f2;
    g = g1 + g2;
    g = g(:);
end

end

