function [Z,F,B,flag] = semisupervised_class(Xlabel,Ylabel,Xunlab,opts)
% Semisupervised estimation - labeled and unlabeled
% 	alternating descent in weighted backward regularized error
% Z is the labels for the unlabeled data, F is the forward model
% and B is the backward model. If there are any errors, flag = -1;
% otherwise, flag == 0.
%
% author: Linli Xu, Martha White, University of Alberta, 2012

DEFAULTS.mu = 0.1;
DEFAULTS.beta = 1e-3;   % Regularization weight for backward model
DEFAULTS.alpha = 1e-4;   % Regularization to recover forward model
DEFAULTS.B0 = [];  % Initial backward model, initialized with supervisde learning on labeled data
DEFAULTS.kernel = @kernel_noop;
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
tl = size(Xlabel,1);
tu = size(Xunlab,1);
Mu = spdiags([ones(tl,1); opts.mu+zeros(tu,1)],0,tl+tu,tl+tu);
t = size(Mu,1);

flag = 0;

I = eye(t);
Mu = spdiags([ones(tl,1); opts.mu+zeros(tu,1)],0,tl+tu,tl+tu);
 
if isempty(opts.B0) 
    [~,~,opts.B0] = supervised_class(Xlabel,Ylabel,Xunlab,opts);
end
fval = Inf;

if isempty(opts.kernel) || isequal(opts.kernel, @kernel_noop)
    B = opts.B0;	% initialize

	Xsemi = [Xlabel;Xunlab];
	for i = 1:opts.MAX_ITERS	% alternating descent for backward model
		Z = Xunlab / B; % optimize Z given B
	    Z = roundY(Z);
	    
		Ysemi = [Ylabel; Z];
		B = (Ysemi'*Mu*Ysemi + opts.beta*eye(k)) \ Ysemi'*Mu*Xsemi; % optimize B given Z
		fvalnew = trace((Xsemi-Ysemi*B)'*Mu*(Xsemi-Ysemi*B))/2;
		if fval - fvalnew < opts.TOL, break; end
		fval = fvalnew;
	end
	
	% % recover forward model
	F = (Xsemi'*Mu*Xsemi + opts.alpha*eye(n)) \ (B'*(Ysemi'*Mu*Ysemi));

else
	B = [opts.B0 zeros(k,tu)];	% initialize
    Klabel = opts.kernel(Xlabel,Xlabel);
    Kunlab = opts.kernel(Xunlab,Xunlab);
    Klabelunlab = opts.kernel(Xlabel,Xunlab);
    Kunlabsemi = [Klabelunlab' Kunlab];
    Ksemi  = [Klabel Klabelunlab; Klabelunlab' Kunlab];
    I = eye(t);	
	Xunlabsq = diag(Kunlab);
    
	for i = 1:opts.MAX_ITERS	% alternating descent for backward model
	%	Z = (Kunlabsemi*B') / (B*Ksemi*B'); % optimize Z given B
	    Bsemisq = diag(B*Ksemi*B');
	    distXunlab = repmat(Xunlabsq, 1, k) + repmat(Bsemisq', tu, 1) - 2*Kunlabsemi*B';
	    [~, indYunlab] = min(distXunlab, [], 2);
	    Z = zeros(tu, k);
	    for j = 1:tu
	        Z(j, indYunlab(j)) = 1;
	    end
	
		Ysemi = [Ylabel; Z];
		B = (Ysemi'*Mu*Ysemi + opts.beta*eye(k)) \ Ysemi'*Mu; % optimize B given Z
		fvalnew = trace(Mu*(I-Ysemi*B)*Ksemi*(I-Ysemi*B)')/2 +opts.beta*trace(B*Ksemi*B')/2;
		if fval - fvalnew < opts.TOL, break; end
		fval = fvalnew;
	end
	
	% % recover forward model
	F = (Mu*Ksemi + opts.alpha*I) \ B'*(Ysemi'*Mu*Ysemi + opts.beta*eye(k));    
end


if any(any(imag(F))) F = real(F); end
if any(any(imag(B))) B = real(B); end
if any(any(imag(Z))) Z = real(Z); end

end
