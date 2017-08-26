function Z = semi_lapsvm(Xl,Yl,Xu,opts)
% Options incldude opts.NN, opts.degree (Laplacian degree) 
% and opts.width specifies the width of the RBF kernel
% if opts.width == [] or non-existent, then a linear kernel is used
%
% authors: Martha White, University of Alberta, 2012


DEFAULTS.NN = 10;  
DEFAULTS.degree = 1;  
DEFAULTS.width = -1;  % Use a linear kernel by default
DEFAULTS.recover = 0;

if nargin < 4
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

if opts.recover == 1
    error('semi_lapsvm -> Cannot obtain forward and backward models, can only label transductively!');    
end
 
% Make options to pass to code created by FINISH
options=make_options();
options.NN = opts.NN; 
if opts.width == -1
    options.Kernel = 'linear';
    opts.kernel = @kernel_linear;
else    
    opts.kernel = @(X1,X2)(kernel_rbf(X1,X2,opts.width));
    options.Kernel='rbf';
    options.KernelParam=opts.width;
    options.GraphWeightParam=opts.width;
end    
options.gamma_A=1e-6;   % As set by the authors in their paper
options.gamma_I=0.01;   % As set by the authors in their paper
options.LaplacianDegree=opts.degree; 
    

X = [Xl;Xu]; 
K = opts.kernel(X,X);
tl = size(Yl,1);
tu = size(Xu,1);
k = size(Yl,2);
if (k == 2) k = 1; end

M=laplacian(options,X);
M=M^options.LaplacianDegree;

% Deform the kernel
r=options.gamma_I/options.gamma_A;
K=Deform(r,K,M);

% Put labeled data in data structure
data.K = K(1:tl,1:tl);
data.X = Xl;
fsvm=[];

% if k = 1, then first col of Yl used at +1, second as -1
for c = 1:k   
    Yc = -1*ones(tl,1);
    Yc(Yl(:,c)==1) = 1; %labeled data converted to -1,1
    data.Y = Yc;
    % Avoid printing from the implementation of svm
    [T classifier_svm] = evalc('svm(options,data)');
    %classifier_svm = svm(options, data);
 
    if isempty(classifier_svm.svs)
      warning(['semi_lapsvm -> Likely there is an error in the balance of your data, setting fsvm to default of ' ...
               'predicting 1'])
      fsvm(:,c) = 1;
    else  
        offset = repmat(classifier_svm.b, tu, 1);
        fsvm(:,c)=K((tl+1):end,classifier_svm.svs)*classifier_svm.alpha - offset;
        if exist('bias','var')
            [fsvm(:,c),classifier_svm.b]  = adjustbias(fsvm(:,c)+offset,  bias);
        end
    end
end

% Now that classifiers obtained, convert back into 0,1;
% currently 1..k
if k==1
     fsvm=sign(fsvm);
     Yu = zeros(tu,2);
     Yu(fsvm==1,1) = 1;
     Yu(fsvm==-1,2) = 1;
else
     [e,fsvm]=max(fsvm,[],2);
     Yu = zeros(tu,k);
     for i=1:tu
        Yu(i,fsvm(i)) = 1;
     end   
end    

Z = Yu;
   	 
	function [f1,b]=adjustbias(f,bias)
	     jj=ceil((1-bias)*length(f));
	     g=sort(f);
	     b=0.5*(g(jj)+g(jj+1));
	     f1=f-b;
	end     
    
end

