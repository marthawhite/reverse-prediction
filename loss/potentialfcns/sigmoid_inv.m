function [Z] = sigmoid_inv(Y)

epsilon = 1e-4;
Y(Y<=0) = epsilon;
Y(Y>=1) = 1-epsilon;
Z = log(Y) - log(1 - Y);
