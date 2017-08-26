function [f,g] = Lfor_cube(X,W,Y)
% f(z) = z^3, F(z) = 1^Tz^4/4
% f = D_F(XW||f^*(Y)) = sum(1^T (XW)^4/4) - YW^T X^T)
% g = X^T(f(XW) - Y) = X^T(XW^3 - Y)
% F(X_tW) - Y_t'W(X_t)
% g = X_t' f(X_tW) - (X_t)'Y_t
  
denom = size(Y,1); %*size(Y,2);
Zhat = X*W;
f = sum(0.25*sum(Zhat.^4,2) - sum(Y.*Zhat,2))/denom;   
if nargout > 1
    Yhat = Zhat.^3;
    g = X'*(Yhat-Y)/denom;
end

end


