function [minIndex,minParams] = crossValidate(params,fcn,Xl,Yl,Xu,Yu,opts)
% CROSSVALIDATE finds the best parameters for the given fcn
% based on prediction accuracy of Yl, or if given Yu, then prediction
% accuracy on [Yl; Yu].
% Parameters:
%      params: Array of options
%      fcn(Xl,Yl,Xu,params{i}) returns [Yhat,What,Uhat], where  Yhat predicts Yu
%      Xl = labeled data features
%      Yl = true targets on labeled data
%      Xu = unlabeled data features, given to each fold.
%      [optional]
%      Yu = true targets on unlabeled (test) data. If given, then error is tested
%           on both Yu and Yl.
%      opts, including 
%           opts.error_fcn to compare accuracy, default = regression_error.
%           opts.num_folds, default = 10.
%       

DEFAULTS.error_fcn = @regression_error;   % Function for comparing accuracy of solution
DEFAULTS.num_folds = 10;   % Number of folds

if nargin < 7
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

num_params = length(params);
if num_params == 1
    minIndex = 1;
    minParams = params{1};
    return;
end 

tl = size(Yl,1);
err_all = zeros(num_params,1);

% Create the folds; if tl < num_folds, cap num_folds
p = randperm(tl); 
opts.num_folds = min(opts.num_folds,tl);
numInEachFold = floor(tl/opts.num_folds);
folds = [];
for i = 1:opts.num_folds
    folds = [folds {p((i-1)*numInEachFold+1:i*numInEachFold)}];
end    

% Cross validate with leave-one-out
for s=1:opts.num_folds
    testInd = folds{s};
    trainInd = [];
    for i = 1:opts.num_folds
        if i == s
            continue;
        end
        trainInd = [trainInd folds{i}];
    end    
    Y_t = Yl(testInd,:);
    X_t = Xl(testInd,:);
    Yl_c = Yl(trainInd,:);;
    Xl_c = Xl(trainInd,:);
    for i=1:num_params
        % Yhat contains predictions for Yu
        Yhat = fcn(Xl_c,Yl_c,[X_t;Xu],params{i});
        if (flag == -1) 
            fprintf(1, 'Could not cross validate function for parameter. Continuing to next parameters...');
            err_all(i) = Inf;
        elseif nargin > 5 && ~isempty(Yu)
            err_all(i) = err_all(i) + opts.error_fcn([Y_t;Yu],Yhat);                
        else
            err_all(i) = err_all(i) + opts.error_fcn(Y_t,Yhat(1:length(testInd),:));
        end 
    end  
end

[minErr,minIndex] = min(err_all);
minIndex = minIndex(1);
minParams = params{minIndex};

end

