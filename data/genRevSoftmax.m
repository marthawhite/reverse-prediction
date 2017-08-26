function [X,Y,U] = genRevSoftmax(t,n,k,sigma)
% GENREVSOFTMAX generates data X,Y and U

U = [];

% Generate random matrix of Y values Y1 = 1
Y = zeros(t,k);
for i = 1:t
    r = floor(k*rand)+1;
    Y(i,r) = 1;
end	

% Two possible reverse data generation approaches
approach = 2;

if approach == 1
    U_t = rand(k,n);
    U = U_t./repmat(sum(U_t,2),1,n);
    N = rand(t,n);
    Q = (1-sigma)*Y*U + sigma*N./repmat(sum(N,2),1,n);
    X = softmax_inv(Q);
else
    % Generate a random X and W,
    % then round Y
    % If Y does not have an entry > min, then throw away row
    minval = 0.7;
    maxiters = 4*t;
    W = randn(n,k);
    Y = [];
    X = [];
    numadded = 0;
    for i = 1:maxiters
        x = randn(1,n);
        y = softmax(x*W);
        if any(y > minval)
            X = [X; x];
            Y = [Y; y];
            numadded = numadded + 1;
            if numadded >= t, break; end
        end     
    end
    Y = roundY(Y);
    X = X+sigma*randn(t,n);

end
