function [match,P] = align(Y,Yhat)
% compute optimal permutation matrix P to make Yhat*P look as close as
% possible to Y
% assuming both Y and Yhat are boolean s.t. sum(Y,2)==1, sum(Yhat,2)==1
% solves
%		max_P tr(Y'*Yhat*P) s.t. P>=0, P1=1, 1'P=1'
%
% If not the same number of classes, then augments Y

[t,kY] = size(Y);
kYhat = size(Yhat,2);
k = max(kY,kYhat);
if (kY == kYhat)
elseif (kY < kYhat)
    Y = [Y zeros(t,k-kY)];
else
    Yhat = [Yhat zeros(t,k-kYhat)];
end

% add symmetry breaking to ensure linprog returns an integral solution
TOL = 1e-4;
Rtmp = rand(t,k);
Rtmp = Rtmp./repmat(sum(Rtmp,2),1,k);
Ytmp = (1 - TOL)*Yhat + TOL*Rtmp;

f = Ytmp'*Y;
f = -f(:);
k2 = k^2;
lb = zeros(k2,1);
ub = ones(k2,1);
Aeq1 = repmat(eye(k),1,k);
cells = num2cell(ones(k),2);
Aeq2 = blkdiag(cells{:});
Aeq = [Aeq1; Aeq2];
beq = ones(2*k,1);
[p,negmatch,flag] = linprog(f,[],[],Aeq,beq,lb,ub,[],optimset('Display','off'));
P = reshape(p,k,k);
F = Yhat'*Y;
match = trace(P'*F);

