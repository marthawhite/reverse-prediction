function [X,Y,W] = genForSigmoid(t,n,k,sigma)
% GENFORSIGMOID generates data X,Y and W

% Generate random X matrix
X = randn(t,n);  
W = randn(n,k);  

Z = X*W + sigma*randn(t,k);
Y = roundY(sigmoid(Z));

end
