function [f,g] = Lrev_softmax(X,Y,U,var)
% f = F^*(YU) - X'(YU)
% F^*(y) = [ln(y)  - ln(y_k)1]y - ln(1'(y-y_k1))
  
  if isempty(X)
  f = 0;
  g = 0;
  return;  
  end
  
% only include g if nargout > 1
if nargout < 2
    var = 0;
elseif nargin < 4
    var = 2;
end

tol = 1e-4;
[denom,xdim] = size(X);
YU = Y*U;
YU(YU < tol) = tol;
%F = (log(YU) - repmat(log(YU(:,end)),1,xdim))'*YU - log(sum(YU-repmat(YU(:,end),1,xdim),2))
f = 0;
for t = 1:denom
    F = (log(YU(t,:)) - repmat(log(YU(t,end)),1,xdim))*YU(t,:)' - log(sum(YU(t,:)-repmat(YU(t,end),1,xdim)));
    f = f + (F - X(t,:)*YU(t,:)');
end
f = f/denom;

% only include g if nargout > 1
g = getGradient(X,Y,U,softmax_inv(YU),var)/denom;


end

