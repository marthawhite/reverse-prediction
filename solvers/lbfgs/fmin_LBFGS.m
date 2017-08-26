function [x,f,flag,iter] = fmin_LBFGS(fun,x0,opts)
% limited memory BFGS
% minimizes fun unconstrained if opts.A, opts.b
% not provided; otherwise, can specify opts.A x >= b
% and/or opts.Aeq x = opts.beq.
% for lb and ub, just set A = [1; -1] and b = [lb; -ub]
%
% Author: Dale Schuurmans, University of Alberta
  
  if ~isa(fun,'function_handle'), error('improper function handle'); end

  % Can also provide opts.Apd, opts.bpd, opts.TOL, which will be used in backtrack
  DEFAULTS.m = 50;  
  DEFAULTS.maxiter = 1000;   
  DEFAULTS.TOL = 1e-6;   
  DEFAULTS.CURVTOL = 1e-3;   
  DEFAULTS.A = [];
  DEFAULTS.b = [];
  DEFAULTS.Aeq = [];
  DEFAULTS.beq = [];
  DEFAULTS.slope_update_fcn = @inequality_update;

  if nargin < 3
    opts = DEFAULTS;
  else
    opts = getOptions(opts, DEFAULTS);
  end

  % Ensure that x0 is a feasible starting point, depending on the constraints
  x = x0;
  if nargout(fun) == 3
    [f,g,constraint_opts] = fun(x);
    % constrain_opts contains linear constrains A, b and/or Aeq, beq
    opts = getOptions(opts, constraint_opts);
  else
    [f,g] = fun(x);
  end    

  flag = 0;
  if ~isempty(opts.Aeq)
    [x,P,flag] = feastartcon(opts.A,opts.b,opts.Aeq,opts.beq,x0);
    opts.slope_update_fcn = @equality_update;
  elseif ~isempty(opts.A)
    [x,flag] = feastartineq(opts.A,opts.b,x0);
  end
  if flag
    warning('constraints infeasible');
    iter = 0;
    f = NaN;
    return
  end

  t = length(x0);
  H0 = speye(t);
  Rho = zeros(1,opts.m);
  Y = zeros(t,opts.m);
  S = zeros(t,opts.m);
  inds = [];
  slope = Inf;

  
  % damped limited memory BFGS method
  for iter = 1:opts.maxiter

    % compute search direction
    slope = opts.slope_update_fcn();
    
    if -slope < opts.TOL, break; end
    [xnew,fnew,flag,gnew] = backtrack(fun,x,f,d,slope,opts);
    if flag break; end

    % update memory for estimating inverse Hessian
    s = xnew - x;
    y = gnew - g;
    curvature = y'*s;
    if curvature > opts.CURVTOL	
      rho = 1/curvature;
      if length(inds) < opts.m
        i = length(inds)+1;
        inds = [inds i];
      else
        i = inds(1);
        inds = [inds(2:end) inds(1)];
      end
      Rho(i) = rho;
      Y(:,i) = y;
      S(:,i) = s;
    end

    x = xnew;
    f = fnew;
    g = gnew;
  end

  if iter == opts.maxiter
    warning('fmin_LBFGS : Maximum number of iterations exceeded, with final slope = %g (and TOL = %g)\n',...
            full(slope), opts.TOL);
    flag = 1;
  end

  function slope = inequality_update()
  % compute search direction
    d = invhessmult(-g,Y,S,Rho,H0,inds,opts.m);
    slope = d'*g;
  end
  
  function slope = equality_update()
  % constrained search direction
		B = invhessmult(Aeq',Y,S,Rho,H0,inds,opts.m);
		hg = invhessmult(g,Y,S,Rho,H0,inds,opts.m);
		y = linsolve(Aeq*B,Aeq*(x-hg) - beq,lin_opts);
		d = -hg - B*y;
		d = d - Aeq'*(P*d);	% re-project onto constraint (numerically helpful)
    
		gproj = g - Aeq'*(P*g);
		slope = d'*gproj;
  end

end