function [X,Y,U] = genRevSigmoid(t,n,k,sigma)
% GENREVSIGMOID generates data X,Y and U

% Generate random matrix of Y values Y1 = 1
    Y = zeros(t,k);
    for i = 1:t
	r = floor(k*rand)+1;
	Y(i,r) = 1;
    end	

    % Two possible reverse data generation approaches
    approach = 2;

    if approach == 1
        U = rand(k,n);
        Q = (1-sigma)*Y*U + sigma*rand(t,n);
        X = sigmoid_inv(Q);
    else
        % Or, using a random W, generate X from Y
        W = randn(n,k);
        X = sigmoid_inv(Y)*pinv(W) + sigma*randn(t,n);
        U = W;
    end

end
