% Classifier Evaluation Routine
% This code provides different methods to evaluate binary classifiers.
%
% Basic Usage : 
% [maxthreshold,maxobj,maxcm]=classifier_evaluation(outputs,labels,func)
% outputs is a vector of real-valued outputs on a test set
% labels are corresponding true labels
% func : function of the type func(totalpositive,totalnegative, falsepositive,falsenegative)
% func = f1 | r1 | acc (accuracy) | info (information)
% maxthreshold-- threshold point at which func maximizes
% maxobj - the maximum function value at this point
% maxcm - the confusion matrix at maxthreshold
%
% Written by Jason Rennie <jrennie@csail.mit.edu>
% Last modified: Thu Feb 19 13:19:32 2004
%
% Modified by Vikas Sindhwani 
% 09/24/2004
%
%

function [maxthresh,maxobj,maxcm] = classifier_evaluation(outputs,labels,func)
  n = length(outputs);
  if n ~= length(labels)
    error('length of outputs and labels must match')
  end
  np = sum(labels>0);
  nn = sum(labels<0);
  fp = nn;
  fn = 0;
  maxobj = feval(func,np,nn,fp,fn);
  [tmp,idx] = sort(outputs);
  so = outputs(idx);
  sl = labels(idx);
  maxthresh = so(1)-1;
  maxcm=[np-fn fn; fp nn-fp];
  for i=1:length(so)-1
    if sl(i) < 0
      fp = fp - 1;
    else
      fn = fn + 1;
    end
    if so(i) == so(i+1)
      continue
    end
    obj = feval(func,np,nn,fp,fn);
    if obj > maxobj
      maxobj = obj;
      maxthresh = (so(i)+so(i+1))/2;
      maxcm=[np-fn fn; fp nn-fp];
      
   end
  end
  if sl(n) < 0
    fp = fp - 1;
  else
    fn = fn + 1;
  end
  obj = feval(func,np,nn,fp,fn);
  if obj > maxobj
    maxobj = obj;
    maxthresh = so(n)+1;
    maxcm=[np-fn fn; fp nn-fp];
  end
  

  function h=info(np,nn,fp,fn)
    cm=[nn-fp fp; fn np-fn]; 
    h=information(cm);
