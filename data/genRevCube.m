function [X,Y,U] = genRevCube(t,n,k,sigma)
% GENREVCUBE generates data X,Y and U

Y = randn(t,k);  
U = randn(k,n);

X = cube_inv(Y*U) + sigma.*randn(t,n);

end
