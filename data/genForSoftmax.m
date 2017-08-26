function [X,Y,W] = genForSoftmax(t,n,k,sigma)
% GENREVSOFTMAX generates data X,Y and U

X = randn(t,n);
W = randn(n,k);
Y = softmax(X*W);
X = X+sigma*randn(t,n);


