function [D] = D_euclidean(Z1,Z2,lambda)

n1 = size(Z1,1);
n2 = size(Z2,1);
d1 = sum(Z1.^2,2);
d2 = sum(Z2.^2,2);

D = (repmat(d1,1,n2) + repmat(d2',n1,1) - 2*Z1*Z2')/2;

if (nargin == 3)
  D = repmat(lambda,1,n2).*D;
end