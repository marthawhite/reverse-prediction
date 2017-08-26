function [x,f,flag,varargout] = backtrack(fun,x0,f0,dir,slope,opts)
% backtrack line search
% varargout contains g, constraint_opts, and iter

DEFAULTS.backtrack_maxiter = 5;   
DEFAULTS.TOL = 1e-4;   
DEFAULTS.backoff = 0.5;    
DEFAULTS.acceptfrac = 0.1;
DEFAULTS.A = [];
DEFAULTS.b = [];
DEFAULTS.Apd = [];
DEFAULTS.bpd = [];

if nargin < 6
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

flag = 0;
varargout = {};
opts.disp = 0;

if any(imag(x0)), 'backtrack'; x=x0;f=f0;varargout{1}=-dir;flag=1;return, end;
if any(imag(f0)), 'backtrack'; x=x0;f=f0;varargout{1}=-dir;flag=1;return, end;
if any(imag(dir)), 'backtrack'; x=x0;f=f0;varargout{1}=-dir;flag=1;return, end;

% linear inequalities
mode_ineq = 0;
if size(opts.A,1) > 0
	mode_ineq = 1; 
	if min(opts.A*x0 - opts.b) < opts.TOL
		warning('infeasible x0 given to backtrack: violates linear inequalities');
		flag = 1;
		x = x0;
		f = f0;
		varargout = cell(1,nargout-3);
		return;
	end
end

% PSD inequality
mode_psd = 0;
if size(opts.Apd,1) > 0
	mode_psd = 1; 
	s = sqrt(length(opts.bpd));
	if s > 0
		if issparse(opts.Apd)
			x0 = sparse(x0);
		end
		M0 = reshape(opts.Apd*x0-opts.bpd,s,s);
		M0 = (M0+M0')/2;
		[R,p] = chol(M0);
		if p
			warning('infeasible x0 given to backtrack: Matrix(Apd*x0-bpd) not posdef');
			flag = 1;
			x = x0;
			f = f0;
			varargout = cell(1,nargout-3);
			return
		end
	end
end

% backtrack
alpha = 1;
for iter = 1:opts.backtrack_maxiter

	x = x0 + alpha*dir;

	if mode_ineq && min(opts.A*x - opts.b) < TOL
		alpha = alpha*opts.backoff; 
		continue 
	end

	if mode_psd
		M = reshape(opts.Apd*sparse(x)-opts.bpd,s,s);
		M = (M+M')/2;
		[R,p] = chol(M);
		if p
			alpha = alpha*opts.backoff; 
			continue 
		end
	end

	f = fun(x);

	if imag(f) % cholesky says psd is ok, but its not, so keep backtracking
		alpha = alpha*opts.backoff;
		continue
	end

	if f < f0 || f < f0 + opts.acceptfrac*alpha*slope 
		break 
	end
	alpha = alpha*opts.backoff;
end

% if maxiters, check feasibility, restore if necessary
if iter == opts.maxiter

	warning('backtrack : Maximum number of backtrack iterations exceeded (%d)', opts.backtrack_maxiter);
	flag = 1;
    
	if mode_ineq && min(opts.A*x - opts.b) < TOL
		x = x0;
	end

	if mode_psd
		M =reshape(opts.Apd*x-opts.bpd,s,s);
		[R,p] = chol(M);
		if p, x = x0; end
	end
end

if nargout == 4
	[f,varargout{1}] = fun(x);
elseif nargout >= 5
	[f,varargout{1},varargout{2}] = fun(x);
end
if nargout >= 6
	varargout{3} = iter; 
end

