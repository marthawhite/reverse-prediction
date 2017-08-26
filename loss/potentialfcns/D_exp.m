function [D] = D_exp(Z1,Z2)
% f(z) = e^z, F(z) = 1^Te^z
% f^-1(y) = ln(y), F*(y) = [ln(y) - 1]^T y^T
% f = D_F*(yU || f(x)) = [ln(yU) - x - 1] U^T y^T
% d/dU: g = y^T [ln(yU) - x]
% d/dY: g = (f^-1(YU) - X)U^T = [ln(YU) - X]U^T
% 

  n1 = size(Z1,1);
  n2 = size(Z2,1);

  f2 = log(Z2);

  F1 = sum((log(Z1) - ones(size(Z1))).*Z1,2);
  F2 = sum((f2 - ones(size(Z2))).*Z2,2);
  
  ff2 = diag(Z2*f2');

  D = repmat(F1,1,n2) - repmat(F2',n1,1) - Z1*f2' + repmat(ff2',n1,1);


end

