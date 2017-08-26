function [Z,flag] = trg(Xl, Yl, Xu, opts)
% TRG implements Cortes' transductive regression algorithm
% phi is the feature vector on training examples X_m and for
% the testing examples (unlabeled) Xu
% [Optional] If K is not provided or K==0, does primal solution
% Note that a model W is produced, but it is only applicable to
% transductively label Xu, so it is not returned.
%
% author: Martha White, University of Alberta, 2012

DEFAULTS.kernel = @kernel_noop;   % No kernel by default
DEFAULTS.C1 = 5;
DEFAULTS.C2 = 5;
DEFAULTS.lambda = 1e-3;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end 

flag = 0;

K = opts.kernel;

% Compute r using approach from TRG paper
tl = size(Yl,1);
n = size(Xl,2);
distances = Xu*[Xl;Xu]';
num_min = min(max(ceil(tl*3/100), 5), tl);
[y,i] = sort(abs(distances));
r = max(max(i(:, num_min)),1);
%r = 10;

Yu = local_krg(Xl, Yl, Xu, K, r);	

% If no kernel function K, do primal solution
if isempty(K) || isequal(K, @kernel_noop)
	W = get_primal_w(Xl, Yl, Xu, Yu);
else
	W = get_dual_w(Xl, Yl, Xu, Yu);	
end
U = [];

Z = Xu*W;

if (isnan(W))		
	fprintf(1, 'trg -> Values too large when multiplying matrices. Solution was a Nan\n');
end
 
%----------------------------------------------------------------
% Transductive regression function: dual and primal 
function W = get_primal_w(Xl, Yl, Xu, Yu)
	C_m = opts.C1;
	C_u = opts.C2;
	N = size(Xl, 2);
	
	W = inv(eye(N) + C_m*Xl'*Xl + C_u*Xu'*Xu)*(C_m*Xl'*Yl + C_u*Xu'*Yu);	
end
 
function W = get_dual_w(Xl, Yl, Xu, Yu)
	C_m = opts.C1;
	C_u = opts.C2;
	m = size(Xl, 1);
	u = size(Xu, 1);
    
	M_x = [sqrt(C_m)*Xl' sqrt(C_u)*Xu'];
	M_y = [sqrt(C_m)*Yl; sqrt(C_u)*Yu];
	K_matrix = M_x'*M_x;
	
	W = M_x*inv(opts.lambda*eye(m+u, m+u) + K_matrix)*M_y;
end

%----------------------------------------------------------------
% Functions for computing local estimates. Most used is local_krg
function Yu = local_krg(Xl, Yl, Xu, K, r)

	u = size(Xu, 1);
	Yu = zeros(u, size(Yl, 2));
	
	for i = 1:u
        if isempty(K) || isequal(K, @kernel_noop)
			indices = (sqrt(sum((repmat(Xu(i, :),tl, 1) - Xl).^2, 2)) <= r);
			W = krg(Xl(indices, :), Yl(indices, :), [], opts.lambda);
			Yu(i, :) = Xu(i, :)*W;			
		else		
			indices = (feval(K, Xu(i, :), Xl) <= r);
			W = krg(Xl(indices, :), Yl(indices, :), K, opts.lambda);
			Yu(i, :) = feval(K, Xu(i, :), Xl(indices, :))*W;			
		end
	end	

end

function W = krg(Xl, Yl, K, lambda)
%KRG does (kernel) ridge regression
        
	if isempty(K) || isequal(K, @kernel_noop)
		W = (opts.lambda*eye(size(Xl,2)) + Xl'*Xl) \ (Xl'*Yl);
	else
		K_matrix = feval(K, Xl, Xl);
		W = (K_matrix + opts.lambda*eye(size(Xl,1))) \ Yl;
	end
	
end


end
