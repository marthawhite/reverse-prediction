function [Z, W, U, flag] = clusterEmBregman(Xl,Yl,Xu,opts)
% CLUSTEREMBREGMAN solves for a mixture model clustering on the 
% labeled data (according to reverse prediction paper algorithm),
% recovers a model and labels unlabelled data.
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

% Obtain loss functions and potential for given transfer
[forloss,revloss,D,f,f_inv] = getLoss(opts.transfer);

% Outright solve for M
onevec = ones(tl,1);
M = pinv(diag(Yl'*onevec))*Yl'*Xl;
  
U = f_inv(M); 
% Optimize for W given labels
W = learnForwardModel(Xl, Yl, forloss);

% Recover Z for Xu
Z = roundY(f(Xu*W));

end  

