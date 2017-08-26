function [Z,F,B,flag] = supervised_ncut(Xl,Yl,Xu,opts)
% weighted regularized kernelized least squares
%
% authors: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.beta = 1e-3;   % Regularization weight for backward model
DEFAULTS.alpha = 1e-4;   % Regularization to recover forward model
DEFAULTS.kernel = @kernel_linear;

if nargin < 3
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

if isequal(opts.kernel, @kernel_noop)
    warning('supervised_ncut -> Must be given a kernel, cannot run with kernel_noop! Changing to linear kernel.');
    opts.kernel = @kernel_linear;
end

K = opts.kernel(Xl,Xl);
K = K-diag(diag(K));
N = diag(K*ones(size(K, 1), 1));
F = (K + opts.alpha*eye(size(Xl,1))) \ Yl;		% forward
B = (Yl'*N*Yl + opts.beta*eye(size(Yl,2))) \ Yl';	% backward
Z = opts.kernel(Xu,Xl)*F;

flag = 0;


