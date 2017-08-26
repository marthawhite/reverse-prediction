function [X,Y,W] = genForExp(t,n,k,opts)
% GENFOREXP generates data X,Y, W with a 
% gaussian distribution and exponential transfer

DEFAULTS.sigma = 0.01;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

W = randn(n,k);
X = randn(t,n);

Y = exp(X*W) + opts.sigma.*randn(t,k);

end
