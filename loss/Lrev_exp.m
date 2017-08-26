function [f,g,exp_constraint_opts] = Lrev_exp(X,Y,U,var,normval)
% f(z) = e^z, F(z) = 1^Te^z
% f^-1(y) = ln(y), F*(y) = [ln(y) - 1] y^T
% f = D_F*(yU || f(x)) = [ln(yU) - x - 1] U^T y^T
% d/dU: g = y^T [ln(yU) - x]
% d/dY: g = (f^-1(YU) - X)U^T = [ln(YU) - X]U^T
% 
% Argument var says which variable to return a gradient for
% var = 2 is U, var = 1 is Y, var = 0 none. Default: var = 2
%
% This function has a lot of safeguards and heuristics because
% the exponential transfer can be very unstable.
%
% NOTE: FUNCTION VALUES CAN BE LESS THAN ZERO BECAUSE WE ARE
% NOT WRITING DOWN THE ENTIRE D_F* (BECAUSE ARE ONLY MINIIZING PART
% WITH Y AND U)

maxValue = 1000;

% only include g if nargout > 1
if nargout < 2
    var = 0;
elseif nargin < 4
    var = 2;
end
if nargin < 5
    normval = 1;
end

denom = size(X,1);

Z = Y*U;
if any(any(Z <= 0)) > 0
    % warning(['Lrev_exp -> YU had a value less than zero, capping Y  ' ...
    %         'and U...']);
    Y(Y <= 0) = 1e-2;
    Z = Y*U;
    if any(any(Z < 0)) > 0
        U(U <= 0) = 1e-2;
        Z = Y*U;
    end    
end    
Xhat = log(Z);
Xhat = real(Xhat);

% If any of Xhat is nan or inf, then likey Z too close to zero.
Xhat(isnan(Xhat)) = -1000;
Xhat(isinf(Xhat)) = -1000;

f = 0;
[t,n] = size(X);
k = size(Y,2);

for i = 1:t
  val = (Xhat(i,:) - X(i,:) - ones(1,n))*(U'*Y(i,:)') +sum(exp(X(i,:)));    
  f = f + val;
end  

if (f == -inf)
  f = -maxValue;
elseif (f == inf)
  f = maxValue;
else
  f = f/normval;
end  
  
f = real(f)/denom;

g = getGradient(X,Y,U,Xhat,var);
% If gradient imaginary, then takes real part
if sum(any(imag(g))) > 0
    g = real(g);
end 
g = g/denom;

% Get constraint function; constraints for var1 only needed to be computed once
% var2 requires on the changing value of Y, so must be recomputed
persistent exp_constraint_opts_var1;
if nargout >= 3
	if var == 2
	    [exp_constraint_opts.A, exp_constraint_opts.b] = Lconst_exp_var2(Y);
	elseif var == 1
        if isempty(exp_constraint_opts_var1)
            [exp_constraint_opts_var1.A, exp_constraint_opts_var1.b] = Lconst_exp_var1();
        end
	    exp_constraint_opts = exp_constraint_opts_var1;
	end
end

    % Constraint to ensure that Y >= 0
    function [A,b] = Lconst_exp_var1()
		A = eye(t*k);
		b = zeros(t*k,1);
    end
    
    % YU >= 0
	% So need to put Y on blkdiagonal since U will been linearized
    function [A,b] = Lconst_exp_var2(Y)
		Acell = [];
		for i = 1:n
			Acell = [Acell {Y}];
		end	
		A = blkdiag(Acell{:});
		b = zeros(size(A,1),1);
    end
end
