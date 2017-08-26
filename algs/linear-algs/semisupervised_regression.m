function [Z,F,B,i] = semisupervised_regression(Xlabel,Ylabel,Xunlab,opts)
% Semisupervised estimation - labeled and unlabeled
% 	alternating descent in kernelized weighted backward regularized error
%
% author: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.mu = 0.1;
DEFAULTS.kernel = @kernel_noop;
DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements

DEFAULTS.TOL = 1e-4;
DEFAULTS.MAX_ITERS = 100;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

n = size(Xlabel,2);
k = size(Ylabel,2);
tl = size(Xlabel,1);
tu = size(Xunlab,1);
Mu = spdiags([ones(tl,1); opts.mu+zeros(tu,1)],0,tl+tu,tl+tu);
t = size(Mu,1);

% Initialize Z and B
[Z, F, B] = supervised_regression(Xlabel, Ylabel, Xunlab, opts);
fval = Inf;

if isempty(opts.kernel) || isequal(opts.kernel, @kernel_noop)
    Xsemi = [Xlabel; Xunlab];
    for i = 1:opts.MAX_ITERS        % alternating descent for backward model
		Z = Xunlab / B;                 % optimize Z given B
		Ysemi = [Ylabel; Z];
		B = Ysemi'*Mu*Ysemi \ Ysemi'*Mu*Xsemi; % optimize B given Z
		fvalnew = trace((Xsemi-Ysemi*B)'*Mu*(Xsemi-Ysemi*B))/2;
		if fval - fvalnew < opts.TOL, break; end
		fval = fvalnew;
    end
    F = (Xsemi'*Mu*Xsemi + opts.alpha*eye(n)) \ (B'*(Ysemi'*Mu*Ysemi));
else
    
	Klabel = opts.kernel(Xlabel,Xlabel);
	Kunlab = opts.kernel(Xunlab,Xunlab);
	Klabelunlab = opts.kernel(Xlabel,Xunlab);
	Kunlabsemi = [Klabelunlab' Kunlab];
	Ksemi  = [Klabel Klabelunlab; Klabelunlab' Kunlab];
	I = eye(t);
	
	F = (Klabel + opts.mu*eye(size(Xlabel,1))) \ Ylabel;
	Z = opts.kernel(Xunlab,Xlabel)*F;
	B = [B zeros(k,tu)];	% initialize
	
	for i = 1:opts.MAX_ITERS	% alternating descent for backward model
		Ysemi = [Ylabel; Z];
		B = (Ysemi'*Mu*Ysemi) \ Ysemi'*Mu; % optimize B given Z
		Z = (Kunlabsemi*B') / (B*Ksemi*B'); % optimize Z given B
		fvalnew = trace(Mu*(I-Ysemi*B)*Ksemi*(I-Ysemi*B)')/2;
		if fval - fvalnew < opts.TOL, break; end
		fval = fvalnew;
	end
	% recover forward model
	F = (Mu*Ksemi + opts.mu*I) \ B'*(Ysemi'*Mu*Ysemi);
end

if (i == opts.MAX_ITERS)
    warning('semisupervised_regression hit the max iteration %d\n', opts.MAX_ITERS);
end

if any(any(imag(F))) F = real(F); end
if any(any(imag(B))) B = real(B); end
if any(any(imag(Z))) Z = real(Z); end
