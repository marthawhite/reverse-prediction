function [D] = D_log(Z1,Z2)
% f(z) = ln(z), F(z) = z^T ln(z) - 1^T z
% f^-1(y) = exp(y), F*(y) = 1^Te^y
% f = D_F*(yU || f(x)) = F(yU) - x^T y U 
% d/dU: g = y^T [ln(yU) - x]
% d/dY: g = (f(YU) - X)U^T = [ln(YU) - X]U^T
% 

  n1 = size(Z1,1);
  n2 = size(Z2,1);

  f2 = exp(Z2);

  F1 = sum(exp(Z1),2);
  F2 = sum(f2,2);
  
  ff2 = diag(Z2*f2');

  D = repmat(F1,1,n2) - repmat(F2',n1,1) - Z1*f2' + repmat(ff2',n1,1);


end

