function [D] = D_sigmoid(Z1,Z2,lambda)
% If lambda provided, instance weighting

  n1 = size(Z1,1);
  n2 = size(Z2,1);


  F1 = sum(log(1 + exp(Z1)),2);
  F2 = sum(log(1 + exp(Z2)),2);
  f2 = sigmoid(Z2);

  ff2 = diag(Z2*f2');

  D = repmat(F1,1,n2) - repmat(F2',n1,1) - Z1*f2' + repmat(ff2',n1,1);

  if (nargin == 3)
    D = repmat(lambda,1,n2).*D;
  end

end

