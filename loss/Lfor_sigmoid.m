function [f,g] = Lfor_sigmoid(X,W,Y,lambda)
% f(z) = sigmoid(z)
% F(z) = 1^T*ln(1+e^-z)
  
denom = size(Y,1); %*size(Y,2);
if nargin < 4
  lambda = ones(denom,1);
end

Zhat = X*W;
F = sum(log(1 + exp(Zhat)),2);
f = sum(lambda.*(F - sum(Y.*Zhat,2)))/denom;   
if nargout > 1
  %Dlambda = repmat(lambda,1,denom);
    Yhat = sigmoid(Zhat);
    g = X'*diag(lambda)*(Yhat-Y)/denom;
end

end


