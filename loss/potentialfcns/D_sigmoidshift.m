function [D] = D_sigmoidshift(Z1,Z2)

C = 1;
D = D_sigmoid(Z1+C,Z2);

end

