function [Y] = sigmoid(Z)

Y = 1 ./ (1 + exp(-Z));
