function [Algs] = getAlgs(algNames)
% Returns all the function pointers corresponding to the Names given
% NOTE: Everything currently transductive, but could be extended 
%  to learning the model M and then using that determine a new Z
%  based on given X
%
% All the functions are given the parameters: Xl, Yl, Xu and opts
% (some internal parameter(s) they use)
%
%               %%% THE SUPERVISED CLASSIFICATION ALGORITHM
% AlgNames = {'SVM', 'LinearSupervisedClass', 'LinearSupervisedNCut', 'KmeansBregman', 'EmBregman',
%               %%% OUR SEMISUPERVISED CLASSIFICATION ALGORITHM
%               'LinearSemiSupervisedClass', 'LinearSemiSupervisedNCut', 'KmeansBregmanSemi', 'EmBregmanSemi',
%               'EmBregmanSemiNormCut',
%               %%% COMPETITOR SEMISUPERVISED CLASSIFICATION ALGORITHM
%               'SemiZhou', 'SemiLapSVM', 'SemiLapRLSC',
%               %%% THE SUPERVISED REGRESSION ALGORITHM
%               'LinearSupervisedReg', 'Regression',
%               %%% THE SEMISUPERVISED REGRESSION ALGORITHM
%                'RegressionSemi',
%               %%% THE COMPETITOR SEMISUPERVISED REGRESSION ALGORITHM
%               'TRG', 'SemiLapRLS'}
% Author: Martha White, University of Alberta, 2012

numAlgs = length(algNames);
Algs = [];

for ii = 1:numAlgs

	if strcmp(algNames{ii}, 'SVM')          % Get SVM function
        Algs = [Algs {svm}];

    elseif strcmp(algNames{ii}, 'LinearSupervisedClass')        
        Algs = [Algs {@supervised_class}];
    
    elseif strcmp(algNames{ii}, 'LinearSupervisedNCut') 
        Algs = [Algs {@supervised_ncut}];
    
    elseif isempty(strfind(algNames{ii}, 'Semi')) && ...
           strncmp(algNames{ii}, 'KmeansBregman', length('KmeansBregman'))  
        Algs = [Algs {@clusterKmeansBregman}];

    elseif isempty(strfind(algNames{ii}, 'Semi')) && ...
           strncmp(algNames{ii}, 'EmBregman', length('EmBregman'))  
        Algs = [Algs {@clusterEmBregman}];
        
    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedClass') 
        Algs = [Algs {@semisupervised_class}];

    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedNCut') 
        Algs = [Algs {@semisupervised_ncut}];
        
    elseif strncmp(algNames{ii}, 'KmeansBregmanSemi', length('KmeansBregmanSemi'))   
        Algs = [Algs {@clusterKmeansBregmanSemi}];
        
        % The only thing differentiating the next two algs are their parameters, 
        % obtained with getParameters
    elseif strncmp(algNames{ii}, 'EmBregmanSemi', length('EmBregmanSemi'))         
        Algs = [Algs {@clusterEmBregmanSemi}];

    elseif strncmp(algNames{ii}, 'EmBregmanSemiNormCut', length('EmBregmanSemiNormCut'))  
        Algs = [Algs {@clusterEmBregmanSemi}];
        
    elseif strcmp(algNames{ii}, 'SemiZhou') %Competitor
        Algs = [Algs {@semi_zhou}];

    elseif strcmp(algNames{ii}, 'SemiLapSVM') %Competitor
        Algs = [Algs {@semi_lapsvm}];

    elseif strcmp(algNames{ii}, 'SemiLapRLSC') %Competitor
        Algs = [Algs {@semi_laprlsc}];
 
    elseif strcmp(algNames{ii}, 'LinearSupervisedReg') 
        Algs = [Algs {@supervised_regression}];

    elseif strncmp(algNames{ii}, 'Regression', length('Regression')) && ... 
              isempty(strfind(algNames{ii}, 'Semi'))
        Algs = [Algs {@Regression}];
        
    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedReg') 
        Algs = [Algs {@semisupervised_regression}];

    elseif strncmp(algNames{ii}, 'RegressionSemi', length('RegressionSemi'))         
        Algs = [Algs {@RegressionSemi}];

    elseif strcmp(algNames{ii}, 'SemiLapRLS') %Competitor
        Algs = [Algs {@semi_laprls}];

    elseif strcmp(algNames{ii}, 'TRG')    
        Algs = [Algs {@trg}]; 
        
    else
        error(['getAlgs -> Cannot currently handle ' algNames{ii} ' must use ' ...
               'predefined algorithms']);
    end

end


end