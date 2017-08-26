function varargout = Lrev_sigmoid(X,Y,U,var)
% f(z) = 1/(1+e^-z), F(z) = 1^T*ln(1+e^-z)
% f^-1(y) = ln(y/(1-y)), F*(y) = y^T(ln(y/(1-y))) + 1^Tln(1-y)
% f = D_F*(yu || f(x)) = x^T((1-e^-x)/(1+e^-x)) -
% xhat^T((1-e^-xhat)/(1+e^-xhat)) + 1^Tln((1+e-xhat)/(1+e^-x))
% d/dU: g = Y^T(f^-1(YU) - X) = Y^T(ln(YU/(1-YU)) - X)
% d/dY: g = (f^-1(YU) - X)U^T = (ln(YU/(1-YU)) - X)U^T
% 
% Argument var says which variable to return a gradient for
% var = 2 is U, var = 1 is Y, var = 0 none. Default: var = 2
%

% only include g if nargout > 1
if nargout < 2
    var = 0;
elseif nargin < 4
    var = 2;
end

denom = size(X,1);
Z = Y*U;
Xhat = sigmoid_inv(Z);  

expX = exp(-X);
expXhat = exp(-Xhat);
f = sum(sum(X.*((1-expX)./(1+expX)),2) - sum(Xhat.*((1-expXhat)./(1+expXhat)),2) ...
            + sum(log((1+expXhat)./(1+expX)),2));

% This gradient requires 0 < YU < 1, so its capped in sigmoid_inv
g = getGradient(X,Y,U,Xhat,var);
  
end
