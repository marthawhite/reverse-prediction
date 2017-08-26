function Y = softmax(Z)
% SOFTMAX computes the post prediction row vectors
% Y correspondig to pre-prediction row vectors Z
% xi(z) = e^z / 1^Te^z where the rightmost column
% of z is ignored

k = size(Z,2);
Z(:,k) = 0;

warning_state = warning('off');
Y = exp(Z)./repmat(sum(exp(Z),2), 1, k);
Y(isnan(Y)) = 0;

% Handle any inf's that may be in Z
infIndices = isinf(exp(Z));
if (~all(infIndices == 0))
	numPerRow = sum(infIndices,2);
	infRows = find(numPerRow > 0);
	Y(infRows,:) = zeros(length(infRows),k);
	for i = 1:length(infRows)
		index_val = infRows(i);
		Y(index_val,isinf(Z(index_val,:))) = 1/numPerRow(index_val);
	end
end
warning(warning_state);
