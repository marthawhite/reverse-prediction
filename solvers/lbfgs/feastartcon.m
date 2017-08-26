function [x,P,flag] = feastartcon(A,b,Aeq,beq,x0)
% checks if x0 feasible: A*x >= b, Aeq*x = beq 
% if x0 infeasible, computes strictly feasible start with LP

TOLeq = 1e-14;
TOL = 1e-8;

flag = 0;
x = x0;
[k,n] = size(A);
[keq,n] = size(Aeq);

if rank(Aeq) < keq
	warning('equality constraint matrix not full rank'); 
	flag = 1;
	P = NaN;
	return
end

P = (Aeq*Aeq') \ Aeq;
%Proj = eye(length(x0)) - Aeq'*P;	% projection matrix

% check if already strictly feasible
if all(A*x >= b+TOL) && norm(Aeq*x-beq) < TOLeq
	return
end

% if x0 infeasible, compute feasible start
ff = [zeros(n,1); -1];
AA = [-A ones(k,1); zeros(1,n) 1];
bb = [-b-TOL; 1/n];
AAeq = [Aeq zeros(keq,1)];

% linprog
[z,val,lflag] = linprog(ff,AA,bb,AAeq,beq,[],[],[],optimset('Display','off'));

% cplex
%AAA = [AA; AAeq];
%bbb = [bb; beq];
%ctype = [repmat('L',size(AA,1),1); repmat('E',size(AAeq,1),1)];
%vtype = repmat('C',size(AAA,2),1);
%[z,val,lflag] = cplexmex(1,[],ff,AAA,bbb,ctype,[],[],vtype);

flag = lflag - 1;
x = z(1:end-1);
