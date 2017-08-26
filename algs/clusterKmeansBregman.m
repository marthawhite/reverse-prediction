function [Z, W, U, flag] = clusterKmeansBregman(Xl,Yl,Xu,opts)
% CLUSTERKMEANSBREGMAN uses Kmeans to find an optimal hard 
% clustering on the labeled data, recovers a model
% and labels unlabeled data.
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
    error('clusterKmeansBregman requires at least Xl, Yl and Xu.');
end

DEFAULTS.kernel = @kernel_noop;
DEFAULTS.transfer = 'Euclidean';


DEFAULTS.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
DEFAULTS.verbose = 0;	% 0 or 1: nothing, 2: print out optimization statements

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

tl = size(Xl,1);
k = size(Yl,2);

% If kernel = kernel_noop, then runs alg without kernel
Xu = opts.kernel(Xu,Xl);
Xl = opts.kernel(Xl,Xl);     

% instance weighting for data (norm cut) not yet implemented
weights = ones(size(Xu,1)+size(Xl,1),k);

% Obtain loss functions and potential for given transfer
[forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);

% Outright solve for M
for j = 1:k
	M(j,:) = sum(Xl(Yl(:,j)==1,:),1);	
end
  
U = f_inv(M); 
% Optimize for W given labels
W = learnForwardModel(Xl, Yl, forloss);

% Recover Z for Xu
Z = roundY(f(Xu*W));

end  

