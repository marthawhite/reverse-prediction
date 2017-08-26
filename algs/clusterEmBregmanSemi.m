function [Z,W,U,flag] = clusterEmBregmanSemi(Xl,Yl,Xu,opts)
% CLUSTEREMBREGMANSEMI uses EM-like algorithm in reverse prediction
% paper to find a locally optimal probabilistic clustering in a
% semisupervised setting. The data is labeled transductively
% but forward and reverse models are also returned.
%
% Note that this algorithm incorporates extended graph cut
% with instance weighting, using opts.lambda.
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
    error('clusterEmBregmanSemi requires at least Xl, Yl and Xu.');
  end

  DEFAULTS.mu = 0.1;
  DEFAULTS.alpha = 1e-3;      % Regularizer for the forward loss    
  DEFAULTS.beta = 1e-3;       % Regularizer for the backward loss    
  DEFAULTS.rho = 0.1;
  DEFAULTS.lambda = 0;        % Instance weights; if lambda = 0, no instance weighting
                              % else, mu is overriden. If lambda = -1, then do norm cut 
                              % weighting else used given instance weights
  DEFAULTS.kernel = @kernel_noop;
  DEFAULTS.transfer = 'Euclidean';
  DEFAULTS.M0 = [];           % Default: opts.M0 is k randomly selected rows from X

  DEFAULTS.TOL = 1e-5;
  DEFAULTS.MAX_ITERS = 1000;
  DEFAULTS.epsilon = 1e-5;

  DEFAULTS.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
  DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements

  if nargin < 4
    opts = DEFAULTS;
  else
    opts = getOptions(opts, DEFAULTS);
  end

  tl = size(Xl,1);
  tu = size(Xu,1);
  X = [Xl;Xu];
  t = tl+tu;
  k = size(Yl,2);

  % Initialize M with supervised learning solution
  Z = clusterEmBregman(Xl,Yl,Xu,opts);
  Y = [Yl; Z];
  onevec = ones(t,1);  
  
  % If kernel = kernel_noop, then runs alg without kernel
  Xu = opts.kernel(Xu,X);
  X = opts.kernel(X,X);     
  M = pinv(diag(Y'*onevec))*Y'*X;
  
  p = ones(k,1)/k;
  Yu = [];

  % instance weighting for unlabeled data and for norm cut
  if opts.mu == 1
    weights = ones(t,k);
  else    
    weights = [ones(tl,k)/(tl+opts.mu*tu);ones(tu,k)*(opts.mu/(tl+opts.mu*tu))];
  end 
  if opts.lambda ~= 0
    lambda = opts.lambda;
    if lambda == -1
      lambda = sum(X,2);
    end    
    weights = repmat(lambda,1,k).*weights;
    weights = weights./sum(weights(:,1));
  end    

  % Obtain loss functions and potential for given transfer
  [forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);

  A = weights.*D(X,M);
  diff = logsumexp(-opts.rho*A.*repmat(log(p)',t,1));
  diff_prev = Inf;
  count = 0;
  M = [];
  while (abs(diff-diff_prev) > opts.TOL)
    Au = A((tl+1):end,:);
    Yu = repmat(p',tu,1).*exp(-opts.rho*(Au - repmat(min(Au,[],2),1,k)));
    
    Yu = Yu./repmat(sum(Yu,2),1,k);
    
    % Optimize M and p, weight unlabeled with opts.mu
    Y = [Yl;Yu];
    M = pinv(diag(Y'*onevec))*Y'*X;
    p = Y'*onevec/t;
    
    % If any values in p are really small, shift by epsilon
    p(p < 1e-4) = 1e-4;
    p = p./sum(p);
    
    if (count >= opts.MAX_ITERS)
      warning(['clusterEmBregmanSemi -> Could not converge in ' opts.MAX_ITERS 'steps\n']);
      break;
    end
    count = count+1;
		
    A = weights.*D(X,M);	
    diff_prev = diff;
    diff = logsumexp(-opts.rho*A.*repmat(log(p)',t,1));		
  end

  if (any(isinf(p)))
    Yu = ones(size(Yu))/k;
  end

  Z = roundY(Yu);
  % Recover U from the recovered M
  if nargout > 1
    U = f_inv(M);
    % Optimize for W given labels
    W = learnForwardModel(X, [Yl;Z], forloss);
    % Recover Z for Xu
    Z = roundY(f(Xu*W));
  end
  
end


