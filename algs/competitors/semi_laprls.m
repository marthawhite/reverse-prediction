function [Z,W,U,flag] = semi_laprls(Xl, Yl, Xu, opts)
% Params contains kernel width and weights gammaA and gammaI
% Run for semisupervised regression.
%
% author: Martha White, University of Alberta, 2012

DEFAULTS.kernel = @kernel_linear;   % Linear kernel by default
DEFAULTS.gamma_A = 1e-4;
DEFAULTS.gamma_I = 1;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end


flag = 0;

tl = size(Xl, 1);
tu = size(Xu, 1);
k = size(Yl, 2);

% compute the kernel
X = [Xl; Xu];
[t,n] = size(X);
K = opts.kernel(X,X);
L = diag(sum(K,2)) - K;
J = diag([ones(tl,1);zeros(tu,1)]); 
Y = [Yl;zeros(tu,k)];
alpha = (J*K + opts.gamma_A*tl*eye(t) + (opts.gamma_I*tl/t)*L*K) \ Y;

W = alpha;
U = [];
Z = opts.kernel(Xu,X)*W;

end

