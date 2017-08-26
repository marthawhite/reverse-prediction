function [Z, W, U, flag] = RegressionSemi(Xl, Yl, Xu, opts)
% REGRESSION_SEMI solves the alternating reverse prediction problem
% approach for the general unconstrained semisupervised setting:
%
% min_{Z,U} loss_fcn(Xl, Yl*U)/tl + mu*loss_fcn(Xu,ZU)/tu + beta*tr(UU^T)
%
%
%% Inputs:
%   Xl: labeled input data
%   Yl: labeled targets
%   Xu: unlabeled data; if empty, then performs supervised reverse regression
%   opts: options to optimization e.g. transfer function.
%       See DEFAULT below for all possible options and their
%       default values.
%
% author: Martha White, University of Alberta, 2012

if nargin < 3
    error('RegressionSemi requires at least Xl, Yl and Xu.');
end

DEFAULTS.mu = 0.1;
DEFAULTS.beta = 0.1;        % Regularization parameter; if 0, no regularization
DEFAULTS.lambda = 0;        % Instance weights; if lambda = 0, no instance weighting
                            % else, mu is overriden. If lambda = -1, then do norm cut 
                            % weighting else used given instance weights
DEFAULTS.kernel = @kernel_noop;
DEFAULTS.transfer = 'Euclidean';        
DEFAULTS.regularizer = @regularizer;    % no kernel regularizer in backwards U, because kernel not used on Y    

DEFAULTS.TOL = 1e-4;
DEFAULTS.maxiter = 500;
DEFAULTS.maxtime = 500;
DEFAULTS.numrestarts = 3;
DEFAULTS.epsilon = 1e-5;
DEFAULTS.lbfgs_params = struct('TOL', 1e-5, 'maxiter', 200);
%DEFAULTS.optimizer = @(fcn,xinit,params)(fminunc(fcn,xinit,optimset('GradObj','on', 'MaxFunEvals',10000))); 
DEFAULTS.optimizer = @(fcn,xinit,params)(fmin_LBFGS(fcn,xinit,params));
DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements
DEFAULTS.compute_lots = 0;	% if 1, then increases maxtime and maxiter

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end
if opts.compute_lots
    opts.maxtime = 600;
    opts.numrestarts = 6;
end

% Obtain loss functions and potential for given transfer
[forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);
if opts.verbose > 1, fprintf(1,'\nRegressionSemi-%s -> Starting...\n\n', opts.transfer); end


tl = size(Xl,1);
tu = size(Xu,1);
k = size(Yl,2);
X = [Xl;Xu]; 
U = [];
Z = [];

if ~isempty(Xu) 
    % Initialize Z with labeled data
    [Z,W,U,flag] = Regression(Xl,Yl,[],opts);    
    Z = f(opts.kernel(Xu,Xl)*W);
    Xu = opts.kernel(Xu,X);     
end
Xl = opts.kernel(Xl,X);
X = opts.kernel(X,X);
n = size(X,2);

if isempty(U)
  %U = randn(k, n);
    U = pinv(Yl)*f(Xl);
end  
fval_prev = loss_U(U(:));  

starttime = cputime;
anealtimes = 0;
maxaneals = 3;

fvals = [];
Zvals = [];
for iter = 1:opts.maxiter
    % Optimize U first
    [Uvec,fval,flag] = opts.optimizer(@loss_U,U(:), opts.lbfgs_params);
    U = reshape(Uvec,[k n]); 
    
    if flag
        warning(['Regression_Semi-%s - > Optimization for U returned with' ...
                'flag %g\n'], opts.transfer, flag);
    end
    
    % Optimize Z second
    if ~isempty(Xu)
        [Zvec,fval,flag] = opts.optimizer(@loss_Z,Z(:),opts.lbfgs_params);
        Z = reshape(Zvec,[tu k]);
        if flag
            warning('Optimization for Z returned with flag %g and for transfer %s\n', flag, opts.transfer);
        end
    end
    
    fval = loss_U(U(:));  
    if (fval_prev < fval)
        warning(['Regression_Semi-%s -> Alternation increased function' ...
                 ' value from %g to %g\n'], opts.transfer, fval_prev,fval);
    end  

    timeout = (cputime-starttime > opts.maxtime);
    if (abs(fval_prev-fval) < opts.TOL || timeout)
      fvals = [fvals fval];
      Zvals = [Zvals {Z}];
      if anealtimes > maxaneals || timeout
        [m,ind] = min(fvals);
        Z = Zvals{ind};
        fval = fvals(ind);
        if timeout
            fprintf(1,'RegressionSemi-%s -> Hit MAXTIME = %g\n', opts.transfer, opts.maxtime);
            flag = -1;
        end
        break;
      else
        % perturb the current solution
        Z = Z + randn(size(Z));
        anealtimes = anealtimes + 1;
      end
    end
   
    fval_prev = fval;

    % Print out progress
    if opts.verbose > 1 && mod(iter,ceil(opts.maxiter/100.0)) == 0, fprintf(1,'%g,', cputime-starttime); end
end
if opts.verbose > 1, fprintf(1,'\n\n'); end

if (iter == opts.maxiter)
    warning('Regression_Semi-%s -> Optimization reached maxiter = %u', opts.transfer, opts.maxiter);
end  

% Obtain forward model W
if nargout > 1
    [~,W,~] = Regression(X,[Yl;Z],[],opts);
end

% Loss fcn for Z
function [f,g,constraint_opts] = loss_Z(Z) 
    Zmat = reshape(Z,[tu k]);
    if nargout < 2
        f = revloss(Xu,Zmat,U,1);
    elseif nargout < 3 || nargout(revloss) == 2
        [f,g] = revloss(Xu,Zmat,U,1);
        g = g(:);
        constraint_opts = [];
    else    
        [f,g,constraint_opts] = revloss(Xu,Zmat,U,1);
        g = g(:);
    end
end

% Loss fcn for U
function [f,g,constraint_opts] = loss_U(U) 
    Umat = reshape(U,[k n]);
    if nargout < 2
        f1 = revloss(Xl,Yl,Umat,2);
        f2 = revloss(Xu,Z,Umat,2);
        f3 = opts.regularizer(Umat);
    elseif nargout < 3 || nargout(revloss) == 2
        [f1,g1] = revloss(Xl,Yl,Umat,2);
        [f2,g2] = revloss(Xu,Z,Umat,2);
        [f3,g3] = opts.regularizer(Umat);
        g = g1+opts.mu*g2 + opts.beta*g3;
        g = g(:);
        constraint_opts = [];
    else    
        [f1,g1,constraint_opts1] = revloss(Xl,Yl,Umat,2);
        [f2,g2,constraint_opts2] = revloss(Xu,Z,Umat,2);
        [f3,g3] = opts.regularizer(Umat);
        g = g1+opts.mu*g2 + opts.beta*g3;
        g = g(:);
        constraint_opts = [];
        if isfield(constraint_opts1, 'A')
            constraint_opts.A = [constraint_opts1.A; constraint_opts2.A];
            constraint_opts.b = [constraint_opts1.b; constraint_opts2.b];
        end
        if isfield(constraint_opts1, 'Aeq')
            constraint_opts.A = [constraint_opts1.Aeq; constraint_opts2.Aeq];
            constraint_opts.b = [constraint_opts1.beq; constraint_opts2.beq];
        end
        if isfield(constraint_opts1, 'Apd')
            constraint_opts.A = [constraint_opts1.Apd; constraint_opts2.Apd];
            constraint_opts.b = [constraint_opts1.bpd; constraint_opts2.bpd];
        end  
    end         
    f = f1+opts.mu*f2 + opts.beta*f3;
end

function [f,g] = regularizer(Umat)
    f = trace(Umat*Umat')/2;
    g = Umat;
end

end

