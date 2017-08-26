function [K] = kernel_rbf(X1,X2,width)

[t1,n] = size(X1);
[t2,n] = size(X2);
S1 = sum(X1.^2,2);
S2 = sum(X2.^2,2);
distance2 = repmat(S1,1,t2) + repmat(S2',t1,1) - 2*X1*X2';
K = exp(-distance2/width);
