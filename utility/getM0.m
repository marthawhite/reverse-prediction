function M0 = getM0(Xl,Yl,Xu,opts)
% GETM0 obtains a initial M0 = f^{-1}(U) using semisupervised_regression
% parmeters in opts include the inverse transfer, opts.f_inv, and any
% parameters for semisupervised_regression (including kernel and mu).
%
% author: Martha White, University of Alberta, 2012

DEFAULTS.f_inv = @identity;   % inverse function for transfer

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

[~,U,~] = semisupervised_regression(Xl,Yl,Xu,opts);
M0 = f_inv(U);
   
end

