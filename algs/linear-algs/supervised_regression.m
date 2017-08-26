function [Z,F,B,flag] = supervised_regression(Xl,Yl,Xu, opts)
% weighted least squares
%
% authors: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.beta = 1e-3;   % Regularization weight for backward model
DEFAULTS.alpha = 1e-4;   % Regularization to recover forward model
DEFAULTS.kernel = @kernel_noop;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

if isempty(opts.kernel) || isequal(opts.kernel, @kernel_noop)   
    F = (Xl'*Xl + opts.beta*eye(size(Xl,2))) \ Xl'*Yl;      % forward
    B = (Yl'*Yl + opts.beta*eye(size(Yl,2))) \ (Yl'*Xl);    % backward
    Z = Xu*F;
else
    K = opts.kernel(Xl,Xl);
    F = (K + opts.alpha*eye(size(Xl,1))) \ Yl;		% forward
    B = (Yl'*Yl) \ Yl';						% backward
    Z = opts.kernel(Xu,Xl)*F;
end

flag = 0;

end
