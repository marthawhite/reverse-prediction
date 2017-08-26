function [C] = roundY(Y)
% rounds a probabilistic classification matrix Y 
% into a hard classification matrix C

[t,k] = size(Y);
% if Y is 1-dim with {-1,1}, convert to 2 dimensions
if (k == 1)
    Y(Y == -1) = 0;
    C = [Y mod(Y+1,2)];
    return;
end
[ymax,classes] = max(Y,[],2);
inds = sub2ind([t k],(1:t)',classes);
C = zeros(t,k);
C(inds) = ones(t,1);
