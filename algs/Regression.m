function [Z, W, U, flag] = Regression(Xl, Yl, Xu, opts)
% REGRESSION solves the labelled reverse prediction problem
% approach for constrained supervised prediction
%
% min_{U} loss_fcn(Xl, Yl*U)/tl + beta*tr(UU^T)
% Z = f(Xu*W)
%
% Note: Currently does not return a reverse model, U, returns U = [].
%
%% Inputs:
%   Xl: labeled input data
%   Yl: labeled targets
%   Xu: unlabeled data
%   opts: options to optimization e.g. transfer function.
%       See DEFAULT below for all possible options and their
%       default values.
%
% author: Martha White, University of Alberta, 2012

if nargin < 3
    error('Regression requires at least Xl, Yl and Xu.');
end

DEFAULTS.beta = 0.1;        % Regularization parameter; if zero, no regularization
DEFAULTS.lambda = 0;        % Instance weights; if lambda = 0, no instance weighting
                            % else, mu is overriden. If lambda = -1, then do norm cut 
                            % weighting else used given instance weights
DEFAULTS.kernel = @kernel_noop;
DEFAULTS.transfer = 'Euclidean';        
DEFAULTS.regularizer = @regularizer;        

DEFAULTS.TOL = 1e-8;
DEFAULTS.MAX_ITERS = 1000;
DEFAULTS.MAX_TIME = 500;
DEFAULTS.epsilon = 1e-5;
DEFAULTS.lbfgs_params = struct('TOL', 1e-8, 'maxiter', 100);
DEFAULTS.optimizer = @(fcn,xinit,lbfgs_opts)(fmin_LBFGS(fcn,xinit,lbfgs_opts));
%DEFAULTS.optimizer = @(fcn,xinit,params)(fminunc(fcn,xinit,optimset('GradObj','on', 'MaxFunEvals',10000)));

DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

tl = size(Xl,1);
k = size(Yl,2);
    
% Obtain loss functions and potential for given transfer
[forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);

X = Xl;
Xl = opts.kernel(Xl,X);
n = size(Xl,2);

% If have actual kernel, make it the kernel regularizer
%if ~isequal(opts.kernel,@kernel_noop)
%    opts.regularizer = @kernel_regularizer;
%end 

% Obtain forward model W
% Initilaize randomly
%W = rand(n,k);
% Initialize with approximation XW = f^{-1}(Y) gives W = pinv(X)f^{-1}(Y)
W = pinv(Xl)*f_inv(Yl);
if nargout(forloss) > 2
    [Wvec,fval,flag] = opts.optimizer(@loss_W_constrained,W(:),opts.lbfgs_params);
else
    [Wvec,fval,flag] = opts.optimizer(@loss_W,W(:),opts.lbfgs_params);
end

W = reshape(Wvec,[n k]);
if flag
    warning('Regression -> Optimization for W returned with flag %g with transfer %s', flag, opts.transfer);
end

% Usually do not need U for supervised case; Xu might also sometimes be empty
Z = []; U = [];
if ~isempty(Xu)
    Xu = opts.kernel(Xu,X);
    Z = f(Xu*W);
end

% Loss fcn for W
function [f,g] = loss_W(W) 
    Wmat = reshape(W,[n k]);
    if nargout > 1
        [f,g] = forloss(Xl,Wmat,Yl);
        [f,g] = addRegularizerBoth(Wmat,f,g);
    else
        f = forloss(Xl,Wmat,Yl);
        f = addRegularizerf(Wmat,f);
   end        
end

function [f,g,constraint_opts] = loss_W_constrained(W) 
    Wmat = reshape(W,[n k]);
    if nargout >= 3
        [f,g,constraint_opts] = forloss(Xl,Wmat,Yl);
        [f,g] = addRegularizerBoth(Wmat,f,g);
    elseif nargout > 1
        [f,g] = forloss(Xl,Wmat,Yl);
        [f,g] = addRegularizerBoth(Wmat,f,g);
    else
        f = forloss(Xl,Wmat,Yl);
        f = addRegularizerf(Wmat,f);  
    end    
end

% Adds regularizers and linearizes gradient
function [f,g] = addRegularizerBoth(Wmat,f,g)
    if opts.beta ~= 0
        [f2,g2] = opts.regularizer(Wmat);
        f = f+opts.beta*f2;
        g = g+opts.beta*g2;
    end
    g = g(:);
end

function f = addRegularizerf(Wmat,f)
    if opts.beta ~= 0
        f2 = opts.regularizer(Wmat);
        f = f+opts.beta*f2;
    end
end

function [f,g] = regularizer(Wmat)
    f = trace(Wmat*Wmat')/2;
    if nargout > 1
        g = Wmat;
    end
end

function [f,g] = kernel_regularizer(Wmat)
    f = trace(Wmat*Wmat'*Xl')/2;
    if nargout > 1
        g = Xl*Wmat;
    end
end

end

