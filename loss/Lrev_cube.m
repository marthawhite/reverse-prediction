function [f,g] = Lrev_cube(X,Y,U,var)
% f(z) = z^3, F(z) = 1^Tz^4/4
% f^-1(y) = y^(1/3), F*(y) = y^Ty^(1/3) - 0.25*y^(4/3)*1
% f = D_F*(yU || f(x)) = (yU)^(1/3)*U^Ty^T - 0.25*(yU)^(4/3)*1 - x U^T y^T
% d/dU: g = Y^T [f^{-1}(YU) - X] = Y^T[(YU)^(1/3) - X]
% d/dY: g = (f^-1(YU) - X)U^T = [(YU)^(1/3) - X]U^T
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

if isempty(X)
  f = 0;
  g = 0;
  return;  
end

Z = Y*U;
Xhat = cube_inv(Z);
denom = size(X,1);
f = sum(sum((Xhat-X).*Z - 0.25*Xhat.^4))/denom;  
g = getGradient(X,Y,U,Xhat,var)/denom;

end
