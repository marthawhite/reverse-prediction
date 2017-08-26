function Ytest = getPrediction(algName, algopts, Xl, Yl, Xu, Xtest,W)
% Returns the predicted Ytest, based on the current parameter settings and
% the algorithm. If only a transductive algorithm, then returns empty.
%
% Author: Martha White, University of Alberta, 2012


%%%%%%%%%%%%%%%%%%%% THE TRANSDUCTIVE ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%

Ytest = [];
% strcmp(algName, 'TRG') 
% strcmp(algName, 'SemiZhou')
% strcmp(algName, 'SemiLapSVM')
% strcmp(algName, 'SemiLapRLSC')
  
    if nargin < 7 || isempty(W)
        return;
    end
    
    if isfield(algopts, 'transfer')
        [forloss,revloss,~,~,algopts.f] = getLoss(algopts.transfer);    
    end
    
%%%%%%%%%%%%%%%%%%%% THE SUPERVISED CLASSIFICATION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%

	if strcmp(algName, 'SVM')
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = sign(algopts.kernel(Xtest,Xl)*W);
        else  
            Ytest = sign(Xtest*W);
        end
        
    % Linear algorithms with no transfer    
    elseif strcmp(algName, 'LinearSupervisedClass')  || ...
            strcmp(algName, 'LinearSupervisedNCut')
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = roundY(algopts.kernel(Xtest,Xl)*W);
        else  
            Ytest = roundY(Xtest*W);
        end
        
    % Algorithms with transfer; ensure not semisupervised    
    elseif isempty(strfind(algName, 'Semi')) && ...
            (strncmp(algName, 'EmBregman', length('EmBregman')) || ...
            strncmp(algName, 'KmeansBregman', length('KmeansBregman')))
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = roundY(algopts.f(algopts.kernel(Xtest,Xl)*W));
        else  
            Ytest = roundY(algopts.f(Xtest*W));
        end 
        
%%%%%%%%%%%%%%%%%%%% THE SEMISUPERVISED CLASSIFICATION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%

    elseif strcmp(algName, 'LinearSemiSupervisedClass') || ...
            strcmp(algName, 'LinearSemiSupervisedNCut')
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = roundY(algopts.kernel(Xtest,[Xl;Xu])*W);
        else  
            Ytest = roundY(Xtest*W);
        end 

    elseif strncmp(algName, 'KmeansBregmanSemi', length('KmeansBregmanSemi')) || ...
            strncmp(algName, 'EmBregmanSemi', length('EmBregmanSemi'))  || ...
            strncmp(algName, 'EmBregmanSemiNormCut', length('EmBregmanSemiNormCut'))
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = roundY(algopts.f(algopts.kernel(Xtest,[Xl;Xu])*W));
        else  
            Ytest = roundY(algopts.f(Xtest*W));
        end         
  

%%%%%%%%%%%%%%%%%%%% THE SUPERVISED REGRESSION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(algName, 'LinearSupervisedReg')         
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = algopts.kernel(Xtest,Xl)*W;
        else  
            Ytest = Xtest*W;
        end        
        
    elseif isempty(strfind(algName, 'Semi')) && ...
           strncmp(algName, 'Regression', length('Regression'))         
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = algopts.f(algopts.kernel(Xtest,Xl)*W);
        else  
            Ytest = algopts.f(Xtest*W);
        end   
        
%%%%%%%%%%%%%%%%%%%% THE SEMISUPERVISED REGRESSION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%
        
    elseif strcmp(algName, 'LinearSemiSupervisedReg') || ...
            strcmp(algName, 'SemiLapRLS')
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = algopts.kernel(Xtest,[Xl;Xu])*W;
        else  
            Ytest = Xtest*W;
        end                 

    elseif strncmp(algName, 'RegressionSemi', length('RegressionSemi'))         
        if isfield(algopts, 'kernel') && ~isequal(algopts.kernel, @kernel_noop)
            Ytest = algopts.f(algopts.kernel(Xtest,[Xl;Xu])*W);
        else  
            Ytest = algopts.f(Xtest*W);
        end         
    end

end
