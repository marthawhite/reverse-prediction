function [X,Y,U] = genRevGaussian(t,n,k,sigma,gen_reals)
% GENREVGAUSSIAN generates data X,Y and U

    if nargin < 5
        gen_reals = 0;
    end

    if gen_reals
        Y = randn(t,k);  
    else  
        % Generate random matrix of Y values Y1 = 1
	Y = zeros(t,k);
	for i = 1:t
            r = floor(k*rand)+1;
            Y(i,r) = 1;
 end	
    end

    U = randn(k,n);
    X = Y*U + sigma.*randn(t,n);

end
