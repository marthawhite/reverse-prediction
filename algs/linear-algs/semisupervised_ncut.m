function [Z,F,B,i] = semisupervised_ncut(Xlabel,Ylabel,Xunlab,opts)
% Semisupervised estimation - labeled and unlabeled
% 	alternating descent in kernelized weighted backward regularized error
%
% author: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.mu = 0.1;
DEFAULTS.beta = 1e-3;   % Regularization weight for backward model
DEFAULTS.alpha = 1e-4;   % Regularization to recover forward model
DEFAULTS.kernel = @kernel_linear;
DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements

DEFAULTS.TOL = 1e-8;
DEFAULTS.MAX_ITERS = 10000;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

n = size(Xlabel,2);
k = size(Ylabel,2);
tl = size(Ylabel,1);
tu = size(Xunlab,1);

Mu = spdiags([ones(tl,1); opts.mu+zeros(tu,1)],0,tl+tu,tl+tu);
 
if isequal(opts.kernel, @kernel_noop)
    warning('semisupervised_ncut -> Must be given a kernel, cannot run with kernel_noop! Changing to linear kernel.');
    opts.kernel = @kernel_linear;
end

t = size(Mu,1);

% Initialize B and Z
[Z,F0,B0] = supervised_ncut(Xlabel,Ylabel,Xunlab,opts);

Klabel = opts.kernel(Xlabel,Xlabel);
Kunlab = opts.kernel(Xunlab,Xunlab);
Klabelunlab = opts.kernel(Xlabel,Xunlab);
Kunlabsemi = [Klabelunlab' Kunlab];
Ksemi  = [Klabel Klabelunlab; Klabelunlab' Kunlab];
Ksemi = Ksemi - diag(diag(Ksemi));
I = eye(t);
N = diag(Ksemi*ones(size(Ksemi, 1), 1));

fval = Inf;
B = [B0 zeros(k,tu)];	% initialize

Xunlabsq = diag(Kunlab);
XunlabsqM = repmat(Xunlabsq, 1, k);
MuN = Mu*N;
N_inv = I;
Ysemi = [];
for i = 1:opts.MAX_ITERS	% alternating descent for backward model
    
	Ysemi = [Ylabel; Z];
    YsemiMuN = Ysemi'*MuN;
	B = (YsemiMuN*Ysemi + opts.beta*eye(k)) \ Ysemi'*Mu; % optimize B given Z
    
    %	Z = (Kunlabsemi*B') / (B*Ksemi*B'); % optimize Z given B
    %roundY(Z);
    Bsemisq = diag(B*Ksemi*B');
    distXunlab =  XunlabsqM + repmat(Bsemisq', tu, 1) - 2*Kunlabsemi*B';
    [junk, indYunlab] = min(distXunlab, [], 2);
    Z = zeros(tu, k);
    for j = 1:tu
        Z(j, indYunlab(j)) = 1;
    end
    
    YsemiB = Ysemi*B;
	fvalnew = trace(MuN*(N_inv-YsemiB)*Ksemi*(N_inv-YsemiB)')/2;
	if fval - fvalnew < opts.TOL, break; end
	fval = fvalnew;
end

% % recover forward model
F = (MuN*Ksemi + opts.alpha*I) \ B'*(Ysemi'*MuN*Ysemi + opts.beta*eye(k));
 
end 
