function [f,g] = Lfor_softmax(X,W,Y)
  
denom = size(Y,1);
if nargin < 4
  lambda = ones(denom,1);
end
if any(any(Y <= 0))
    epsilon = 1e-8;
    Y(Y <= epsilon) = epsilon;
end 

Zhat = X*W;
F = logsumexp(Zhat,2);
f = sum(lambda.*(F - sum(Y.*Zhat,2)))/denom;   
if nargout > 1
    Yhat = softmax(Zhat);
    g = X'*diag(lambda)*(Yhat-Y)/denom;
end

end


