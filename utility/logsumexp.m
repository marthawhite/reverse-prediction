function lse = logsumexp(x,dim)
% lse = logsumexp(x,dim)
%
% returns the log of sum of exps
% computes lse = log(sum(exp(x),dim))
% but in a way that tries to avoid underflow/overflow
%
% basic idea: shift before exp and reshift back
% log(sum(exp(x))) = alpha + log(sum(exp(x-alpha)));
%

if length(x(:)) == 1 
	lse = x; 
	return
end

xdims = size(x);
if nargin < 2
	nonsingletons = find(xdims > 1);
	dim = nonsingletons(1);
end

alpha = max(x,[],dim) - log(realmax) + 2*log(xdims(dim));
repdims = ones(size(xdims)); 
repdims(dim) = xdims(dim);
lse = alpha + log(sum(exp(x - repmat(alpha,repdims)),dim));

mask = isinf(alpha);
lse(find(mask)) = Inf;

