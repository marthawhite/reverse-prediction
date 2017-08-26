function [D] = D_cube(Z1,Z2)
% D_F(Z1,Z2) = F(Z1) - F(Z2) - f(Z2)(Z1-Z2)
% F(z) = 1^T z.^4/4

%D = 0.25*sum(sum(Z1.^4)) - 0.25*sum(sum(Z2.^4)) - cube(Z2)*(Z1-Z2);

n1 = size(Z1,1);
n2 = size(Z2,1);

F1 = sum(0.25*Z1.^4,2);
F2 = sum(0.25*Z2.^4,2);
f2 = cube(Z2);
ff2 = diag(Z2*f2');

D = repmat(F1,1,n2) - repmat(F2',n1,1) - Z1*f2' + repmat(ff2',n1, 1);

end

