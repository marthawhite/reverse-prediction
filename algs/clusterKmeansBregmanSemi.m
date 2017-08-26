function [Z, W, U, flag] = clusterKmeansBregmanSemi(Xl,Yl,Xu,opts)
% CLUSTERKMEANSBREGMANSEMI uses Kmeans to find a locally
% optimal hard clustering in the semisupervised setting.
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
  error('clusterKmeansBregmanSemi requires at least Xl, Yl and Xu.');
end

DEFAULTS.mu = 0.1;
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

% If kernel = kernel_noop, then runs alg without kernel
Xu = opts.kernel(Xu,X);
Xl = opts.kernel(Xl,X);
X = opts.kernel(X,X);     

if isempty(opts.M0) || any(any(isnan(opts.M0))) || ...
      any(any(isinf(opts.M0))) || any(any(imag(opts.M0)))
  idx = randperm(t);
  opts.M0 = X(idx(1:k),:);
  for j = 1:k
    opts.M0(j,:) = sum(Xl(Yl(:,j)==1,:),1);	
  end  
end 

M = opts.M0;

% instance weighting for unlabeled data and for norm cut
if opts.mu == 1
  weights = ones(t,k)/t;
else    
  weights = [ones(tl,k)/(tl+opts.mu*tu);ones(tu,k)*(opts.mu/(tl+opts.mu*tu))];
end 

% Obtain loss functions and potential for given transfer
[forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);

Y = [];
DXM = D(X,M);
DXM(isnan(DXM)) = 0;
DXM(isinf(DXM)) = 0;
diff = sum(sum(weights.*DXM));
count = 0;
diff_prev=Inf;

while (abs(diff-diff_prev) > opts.TOL)
	Yu = zeros(tu,k);
	[minVals, minIndices] = min(DXM((tl+1):end,:),[],2); 
	for i = 1:tu
		Yu(i,minIndices(i)) = 1;
 end
 
 Y = [Yl;Yu];
 for j = 1:k
   numTL = sum(Yl(:,j));
   numTU = sum(Yu(:,j));
   if (numTL + numTU ~= 0)
     M(j,:) = (sum(X(Yl(:,j)==1,:),1) + opts.mu*sum(X(Yu(:,j)==1,:),1))/(numTL+opts.mu*numTU);
   end	
 end
 
 if (count >= opts.MAX_ITERS)
   warning('clusterKmeansBregmanSemi -> Could not converge in %u steps with transfer %s',opts.MAX_ITERS,opts.transfer);
   break;
 end
 count = count+1;
 
 diff_prev = diff;
 DXM = D(X,M);
 DXM(isnan(DXM)) = 0;
 DXM(isinf(DXM)) = 0;
 diff = sum(sum(weights.*DXM));		
end

Z = roundY(Yu);
% Recover U from the learned M
if nargout > 1
  U = f_inv(M);
  % Optimize for W given labels
  W = learnForwardModel(X, [Yl;Z], forloss);
end  

