function obj=pre_rec_equal(np,nn,fp,fn);

% use with breakeven.m
% this function maximizes when precision is close to recall
recall = (np-fn)/np;
  if fp+np-fn > 0
    precision = (np-fn)/(fp+np-fn);
  else
    precision = 0;
  end

if precision==0 & recall==0
	obj=0;
else 
     obj=1-(precision-recall)^2;
%      obj=(np+nn)-abs(fp-fn);
end
