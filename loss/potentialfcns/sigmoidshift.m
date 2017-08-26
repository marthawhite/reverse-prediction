function [Y] = sigmoidshift(Z)

C = 1;
Y = 1 ./ (1 + exp(-Z-C));

end
