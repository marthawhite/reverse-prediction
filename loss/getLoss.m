function [forloss,revloss,D,f,f_inv] = getLoss(lossName)
% If no lossname provided, then returns possible lossnames
%
% author: Martha White, University of Alberta, 2012
 
    if nargin < 1
        forloss = {'Euclidean', 'Sigmoid', 'Softmax','SSigmoid',...
                   'WEuclidean','WSigmoid','WSoftmax', 'Exp', 'Log', 'Cube', 'CollinsCube'};
        return;
    end    
    revloss = [];
    if strcmp(lossName, 'Euclidean')
        forloss = @Lfor_euclidean; 
        revloss = @Lrev_euclidean;
        D = @D_euclidean;
        f = @identity;
        f_inv = @identity;     
    elseif strcmp(lossName, 'Sigmoid')
        forloss = @Lfor_sigmoid; 
        D = @D_sigmoid;
        f = @sigmoid;
        f_inv = @sigmoid_inv;
    elseif strcmp(lossName, 'Softmax')
        forloss = @Lfor_softmax; 
        revloss = @Lrev_softmax; 
        D = @D_softmax;
        f = @softmax;
        f_inv = @softmax_inv;
    elseif strcmp(lossName, 'SSigmoid')
        forloss = @Lfor_sigmoidshift; 
        D = @D_sigmoidshift;
        f = @sigmoidshift;
        f_inv = @sigmoidshift_inv;
    elseif strcmp(lossName, 'WEuclidean')
        forloss = @(X,W,Y)(Lfor_euclidean(X,W,Y,diag(X*X'))); 
        D = @(Z1,Z2)(D_euclidean(Z1,Z2,diag(Z1*Z1')));
        f = @identity;
        f_inv = @identity;         
    elseif strcmp(lossName, 'WSigmoid')
        forloss = @(X,W,Y)(Lfor_sigmoid(X,W,Y,diag(X*X'))); 
        D = @(Z1,Z2)(D_sigmoid(Z1,Z2,diag(Z1*Z1')));
        f = @sigmoid;
        f_inv = @sigmoid_inv;
    elseif strcmp(lossName, 'WSoftmax')
        forloss = @(X,W,Y)(Lfor_softmax(X,W,Y,diag(X*X'))); 
        D = @(Z1,Z2)(D_softmax(Z1,Z2,diag(Z1*Z1')));
        f = @softmax;
        f_inv = @softmax_inv;        
    elseif strcmp(lossName, 'Exp')
        forloss = @Lfor_exp; 
        revloss = @Lrev_exp;
        D = @D_exp;
        f = @exp;
        f_inv = @log;    
    elseif strcmp(lossName, 'Log')
        forloss = @Lfor_log; 
        revloss = @Lrev_log;
        D = [];
        f = @log;
        f_inv = @exp; 
    elseif strcmp(lossName, 'Cube')
        forloss = @Lfor_cube; 
        revloss = @Lrev_cube;
        D = @D_cube;
        f = @cube;
        f_inv = @cube_inv; 
    else
        error(['Invalid loss name, cannot currently handle ' lossName]);
    end      
end