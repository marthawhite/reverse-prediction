function [f,g,log_constraint_opts] = Lfor_log(X,W,Y)
% assumes 0 <= X, because f^-1(YU) = exp(YU) = X
% f(z) = log(z), F(z) = [ln(z) - 1]^T z^T
% f = D_F(XW||f^*(Y)) = sum((ln(XW) - 1).*(XW)) - YW^T X^T)
% g = X^T(f(XW) - Y) = X^T(log(XW) - Y)

% NOTE: FUNCTION VALUES CAN BE LESS THAN ZERO BECAUSE WE ARE
% NOT WRITING DOWN THE ENTIRE D_F* (BECAUSE ARE ONLY MINIIZING PART
% WITH Y AND U)

  if any(any(X <= 0))
    X(X <= 0) = 1e-5;
  end 

  t = size(Y,1);
  Zhat = X*W;
  Yhat = log(Zhat);
  f = sum(sum((Yhat-Y-ones(size(Y))).*Zhat));   

  if nargout > 1
    g = X'*(Yhat-Y);
  end

  %persistent log_constraint_opts;
  log_constraint_opts = [];
  %if isempty(log_constraint_opts)
  %  [log_constraint_opts.A, log_constraint_opts.b] = Lconst_log(X);
  %end

% XW >= 0
% So need to put X on blkdiagonal since W will been linearized
% This constrant only needs to be computed once, so save as persistent variables
function [A,b] = Lconst_log(X)
  Acell = [];
  for i = 1:k
    Acell = [Acell {X}];
  end	
  A = blkdiag(Acell{:});
  b = zeros(size(A,1),1);
end

end
