% Generate data needed for getDataInfo
addpath('../scripts');
initialize_matlab();

opts = [];
opts.tl = 1000;
opts.tu = 9000;

opts.numSplits = 100;

t = opts.tl+opts.tu;

Names = {'gaussian-reg', 'cube', 'exp', 'gaussian-class', 'sigmoid', 'softmax'};
n = [30, 20, 5, 30, 5, 5];
k = [5, 3, 1, 5, 2, 2];
sigma = 0.1;
dataGens = {@(t,n,k)(genRevGaussian(t,n,k,sigma,1)), ...
           @(t,n,k)(genRevCube(t,n,k,sigma)),...
           @(t,n,k)(genRevExp(t,n,k,sigma)),...
           @(t,n,k)(genRevGaussian(t,n,k,sigma,0)), ...
           @(t,n,k)(genRevSigmoid(t,n,k,sigma)), ...
           @(t,n,k)(genRevSoftmax(t,n,k,sigma))};

Names = {'gaussian-class', 'sigmoid', 'softmax'};
n = [30, 10, 10];
k = [5, 4, 3];
sigma = [0.1, 0.1, 0.1];
dataGens = {@(t,n,k)(genRevGaussian(t,n,k,sigma(1))),...
            @(t,n,k)(genRevSigmoid(t,n,k,sigma(2))), ...
           @(t,n,k)(genRevSoftmax(t,n,k,sigma(3)))};

% The last one is the only one used, since these
% variables below overwrite the ones above
% Comment this our or delete if you want to use the
% above options
Names = { 'gaussian-class'};
n = [30];
k = [5];
sigma = [1.5];
dataGens = {@(t,n,k)(genRevGaussian(t,n,k,sigma(1)))};

%Names = {'sigmoid'};
%n = [10];
%k = [4];
%sigma = [1.5];
%dataGens = {@(t,n,k)(genRevSigmoid(t,n,k,sigma(1)))};


for i = 1:length(Names)
    opts.name = Names{i};
    opts.gen = dataGens{i};
    opts.n = n(i);
    opts.k = k(i);
    opts.sigma = sigma(i);
    saveSplit(opts);
end
