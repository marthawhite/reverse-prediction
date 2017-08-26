function [f,g] = Lrev_euclidean(X,Y,U,var)
% f(z) = z, F(z) = 1/2 z^2
% f^-1(y) = z, F*(y) = 1/2 y^2
% f = D_F*(yu || f(x)) = 1/2 sum((x-yu)^2)
% d/dU : g = Y^T(f^-1(YU) - X) = Y^T(YU - X)
% d/dZ: g = (f^-1(YU) - X)U^T = (YU - X)U^T
% 
% Argument var says which variable to return a gradient for
% var = 2 is U, var = 1 is Z, var = 0 none. Default: var = 2

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

denom = size(X,1);
YU = Y*U;
f = sum(sum((YU - X).^2))/(2*denom);

% only include g if nargout > 1
g = getGradient(X,Y,U,YU,var)/denom;

end

