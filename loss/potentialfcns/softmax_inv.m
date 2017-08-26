function Z = softmax_inv(Y)
% SOFTMAX_INV computes the pre prediction row vectors
% Z correspondig to post-prediction row vectors Z
% xi_inv(y) = ln(y) - ln(y_k)1

t = size(Y,1);
k = size(Y,2);

Z = log(Y) - repmat(log(Y(:,k)),1,k);
Z(isnan(Z)) = 0;
	
%if (~all(Z(:,k) == 0))
% fprintf(2, 'softmax_inv -> Z_k is not zero\n');
%end 