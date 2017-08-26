function [f,g] = Lrev_log(X,Y,U,var)
% f^-1(y) = e^y, F*(y) = 1^Te^y
% f(z) = ln(z), F(z) = [ln(z) - 1]^T z^T
% f = D_F*(yU || f(x)) = 1^T e^(yU) - x U^T y^T
% d/dU: g = y^T [e^(yU) - x]
% d/dY: g = (f^-1(YU) - X)U^T = [e^(YU) - X]U^T
% assumes 0 <= X

% f(z) = ln(z), F(z) = z^T ln(z) - 1^T z
% f^-1(y) = exp(y), F*(y) = 1^Te^y
% f = D_F*(yU || f(x)) = F(yU) - x^T y U 
% d/dU: g = y^T [ln(yU) - x]
% d/dY: g = (f(YU) - X)U^T = [ln(YU) - X]U^T
    
% Argument var says which variable to return a gradient for
% var = 2 is U, var = 1 is Y, var = 0 none. Default: var = 2
%
% NOTE: FUNCTION VALUES CAN BE LESS THAN ZERO BECAUSE WE ARE
% NOT WRITING DOWN THE ENTIRE D_F* (BECAUSE ARE ONLY MINIIZING PART
% WITH Y AND U)

% assumes 0 <= Y
% f(z) = e^z, F(z) = 1^T e^z
% f = D_F(XW||f^*(Y)) = sum(1^T e^XW) - YW^T X^T)
% g = X^T(f(XW) - Y) = X^T(e^XW - Y)

if any(any(X <= 1e-2))
    warning('Lrev_log -> X cannot have values less than zero');
    X(X <= 1e-2) = 1e-2;
end 


% only include g if nargout > 1
if nargout < 2
    var = 0;
elseif nargin < 4
    var = 2;
end
denom = size(X,1);

Z = Y*U; 
Z = real(Z);

% If Z values too large, then cap them
if any(any(Z > 10))
    Z(Z > 10) = 10;
end 
Xhat = exp(Z);

Xhat(isnan(Xhat)) = 0;
Xhat(isinf(Xhat)) = 0;
f = sum(sum(Xhat,2)-sum(X.*Z,2));  
f = real(f)/denom;
g = getGradient(X,Y,U,Xhat,var);

end


