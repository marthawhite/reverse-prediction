function [f,g] = Lfor_euclidean(X,W,Y,lambda)
% f(z) = z, F(z) = 1/2 z^2
% f = D_F(XW||f^*(Y)) = 1/2tr((X*W - Y)^T(X*W-Y))
% g = X^T(f(XW) - Y) = X^T(XW - Y)

denom = size(Y,1);
if nargin < 4
  lambda = ones(denom,1);
end

f = sum(sum(diag(lambda)*((Y - X*W).^2)))/(2*denom);
if nargout > 1
    g = X'*diag(lambda)*(X*W - Y)/denom;
end

end

