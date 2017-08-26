function X = normalizeMatrix(X) 
% NORMALIZEMATRIX makes entries in X have variance 1, mean 0
% Each row of X is a training example.  So divide it by its radius.
    num_fea = size(X, 2);
    X = double(X) - double(repmat(mean(X, 2), 1, num_fea));
    radii = sum(X.^2,2);
    X = X./repmat(sqrt(radii),1,size(X,2));
end