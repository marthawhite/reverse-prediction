function D = D_softmax(Z1,Z2,lambda)
% D_SOFTMAX computes the matrix of Bregman
% divergences between all rows of Z1 and Z2
% D_ij = D_xi(Z1_i,: || Z2_j,:)
% D_xi(z1 || z2) = ln(1^Te^z1) - ln(1^Te^z2) - softmax(z2)^t(z1-z2)

n1 = size(Z1,1);
n2 = size(Z2,1);

Z1(:,size(Z1,2)) = 0;
Z2(:,size(Z2,2)) = 0;

F1 = logsumexp(Z1,2);
F2 = logsumexp(Z2,2);
f2 = softmax(Z2);
ff2 = diag(Z2*f2');

D = repmat(F1,1,n2) - repmat(F2',n1,1) - Z1*f2' + repmat(ff2',n1,1); 
	
if (nargin == 3)   
  D = repmat(lambda,1,n2).*D;
end