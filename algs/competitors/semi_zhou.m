function Z = semi_zhou(Xlabel, Ylabel, Xunlab, opts)
% Params contains alpha and kernel; must have kernel
% No recovery of models for semi_zhou, returns error if opts.recover = 1
% author: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.alpha = 1e-4;   % Regularization parameter
DEFAULTS.kernel = @kernel_linear;
DEFAULTS.recover = 0;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

if opts.recover == 1
    error('semi_zhou -> Cannot obtain forward and backward models, can only label transductively!');    
end

tl = size(Xlabel, 1);
tu = size(Xunlab, 1);
k = size(Ylabel, 2);
X = [Xlabel; Xunlab];
[t,n] = size(X);

% compute the kernel
K = opts.kernel(X,X);
W = K - speye(t);
d = W*ones(t, 1);
Drt = diag(1./sqrt(d));
S = Drt*W*Drt;


F = (1-opts.alpha)*(eye(t)-opts.alpha*S) \ [Ylabel; zeros(tu, k)];

[junk, indFunlab] = max(F, [], 2);
YunlabHat = zeros(tu, k);
for j = 1:tu
    YunlabHat(j, indFunlab(tl+j)) = 1;
end

yunlabhat = indFunlab(tl+1:end);

Z = YunlabHat;

end
