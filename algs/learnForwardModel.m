function W = learnForwardModel(X, Y, forloss, opts)
% LEARNFORWARDMODEL Optimize for W given labels
% learned in reverse optimization.

DEFAULTS.TOL = 1e-5;
DEFAULTS.maxiters = 300;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

n = size(X,2);
k = size(Y,2);
Wvec = fmin_LBFGS(@Wloss,rand(n*k,1),opts);
W = reshape(Wvec, [n,k]);


    function [f,g,constraint_opts] = Wloss(Wvec)
        constraint_opts = [];
        Wmat = reshape(Wvec, [n,k]);        
        if nargout >= 3 && nargout(forloss) >= 3
            [f,g,constraint_opts] = forloss(X, Wmat, Y);
            g = g(:);
        elseif nargout >= 2
            [f,g] = forloss(X, Wmat, Y);
            g = g(:);
        else
            f = forloss(X, Wmat, Y);            
        end
    end
    
end