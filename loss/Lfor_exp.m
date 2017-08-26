function [f,g] = Lfor_exp(X,W,Y)
% assumes 0 <= Y
% f(z) = e^z, F(z) = 1^T e^z
% f = D_F(XW||f^*(Y)) = 1^T e^XW - YW^T X^T)
% g = X^T(f(XW) - Y) = X^T(e^XW - Y)

if any(any(Y <= 0))
    warning('Lfor_exp -> Y cannot have values less than zero');
    Y(Y <= 0) = 1;
end 

denom = size(Y,1);
t = size(Y,1);
Zhat = X*W;
Yhat = exp(Zhat);

f = sum(sum(Yhat,2) - sum(Y.*Zhat,2))/denom;
if nargout > 1
    g = X'*(Yhat-Y)/denom;
end

end


