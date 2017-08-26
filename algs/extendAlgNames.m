function [ExtendedAlgs] = extendAlgNames(algNames, transferNames)
% Extends the algnames to include each of the transferNames
%
% Must be an algorithm in
%
%		{KmeansBregman, KmeansBregmanSemi, EmBregman, EmBregmanSemi,
%			EmBregmanSemiNormCut, Regression, RegressionSemi}
%
% Must be a transfer in transfers given by getLoss. Ignores invalid transfers.
% If loss given has a fixed euclidean transfer, then does not augment it, and
% simply puts it at the front of ExtendedAlgs. Nonextendable algorithm include:
%
%		{LinearSupervisedReg, LinearSupervisedClass, LinearSemiSupervisedReg,
%           LinearSemiSupervisedClass, SVM, SemiLapSVM, SemiLapRLSC, SemiZhou}    
%
% Author: Martha White, University of Alberta, 2012
    
    ExtendableAlgNames = 	{'KmeansBregman', 'KmeansBregmanSemi', 'EmBregman', 'EmBregmanSemi',...
			'EmBregmanSemiNormCut', 'Regression', 'RegressionSemi'};
    AllTransfers = getLoss();
    
    [extendableAlgs, nonExtendableAlgs] = getIntersection(algNames, ExtendableAlgNames);   
    [validTransfers, invalidTransfers] = getIntersection(transferNames, AllTransfers);   
    
    if isempty(validTransfers)
        fprintf(2, 'No acceptable transfers in given list:\n');
        transferNames
        fprintf(2, 'Choose transfers from:\n');
        AllTransfers
    elseif ~isempty(invalidTransfers)
        fprintf(2, 'Ignoring following invalid transfers given:\n');
        invalidTransfers        
    end

    ExtendedAlgs = [];
    for i = 1:length(extendableAlgs)
        for j = 1:length(validTransfers)
            ExtendedAlgs = [ExtendedAlgs {[extendableAlgs{i} '-' validTransfers{j}]}];
        end
    end
    
    ExtendedAlgs = [nonExtendableAlgs ExtendedAlgs];
end

