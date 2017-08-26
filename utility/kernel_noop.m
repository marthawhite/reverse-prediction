function [K] = kernel_noop(X1,X2)
% The non-kernel, as in, does not apply any kernels
% is simply convenient for the framework
    
    K = X1;

end
