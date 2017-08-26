function classifier_svm=svm(options, data)
%
% SVM   :  Support Vector Machines Training Routine
%	   (binary classification)
% 
% Inputs:
%
% options -- a data structure with the following fields
% (Use ml_options to make this structure. Type help ml_options)
%
% options.Kernel = 'linear' | 'poly' | 'rbf'
% options.KernelParam = 0 | degree | gamma | dosent_matter
% options.gamma_A == regularization parameters
%       Note: To do semi-supervised inference
%             use options.PointCloud, options.DeformationMatrix
%             and pass the semi-supervised kernel matrix in data.K
% operationally, this code only uses options.gamma_A though options
% should have correct fields since these are saved in the
% output "classifier" data structure
%
% data -- Input data structure with the following fields
%
%     data.X = a N x D data matrix
%     (N examples, each of which is a D-dimensional vector)
%
%     data.Y = a N x 1 label vector (-1,+1)
%
%     data.K = a N x N kernel gram matrix (optional)
%
%
% Output:
%
% classifier : A data structure that encodes the binary classifier.
% (Type 'help saveclassifier').
%
% Notes: Since all kernel classifiers are  of the form
%             sum_i alpha_i K(x,x_i) + b,
%         we save training examples x_i, alpha_i and b in "classifier".
%
% (a) To predict on new examples, use
%                predict(classifier,test_data,test_data_labels)
% (b) For training on multiclass problems, use
%                multiclass(...)
%
%
% Author:
% Vikas Sindhwani vikass@cs.uchicago.edu
%      This makes a mex interface to the LibSVM software.
%
 
disp('Training Support Vector Machine Classifier');

if ~isfield(data,'K')
   error('Kernel Gram matrix not found');
end

C=1/(2*options.gamma_A);
% for reference      [kernel_type  deg gamma coef0  C   
%                     cache   eps svm_type  nu   p  shrinking ]
parameters =         [4            1   1     0      C   ...
                      40.00 0.001  0        0.5 0.1    1     ] ;

% call mex file
disp('Training SVM :');
%%[alpha, svs, b, nsv, nlab] = mexGramSVMTrain(data.K', data.Y', parameters);
%%alpha=alpha';


%[T model] = evalc('svmtrain(data.Y,[(1:size(data.K,1))'' data.K],sprintf(''-t 4 -c %f'',C))');
model = svmtrain(data.Y,[(1:size(data.K,1))' data.K],sprintf('-t 4 -c %f',C));
alpha = model.sv_coef;
svs = full(model.SVs);
nsv = model.nSV;
b = model.rho;
nlab = model.Label;

% libsvm does some weird label switching

 
if nlab(1)==-1
    alpha=-alpha;
        b=-b;
end


bias=1;
if isfield(options,'bias'), bias=options.bias; end
   if bias==0, b=0; end
   if (bias > 0) & (bias < 1),
        f=data.K(svs+1,svs+1)*alpha;
        g=sort(f);
        jj=floor((1-bias)*length(f));
        b=0.5*(g(jj)+g(jj+1));
   end
   %if bias==1, f=data.K(svs+1,svs+1)*alpha; b=-mean(data.Y(svs+1)-f); end
% save classifier 
 
classifier_svm=saveclassifier('svm',svs,alpha,data.X(svs,:),b,options);

%if bias==1 
%  f=K(svs+1,svs+1)*alpha;
%   b=mean(Y(svs+1)-f);
%end

%end    


% save classifier -- records only support vectors
%classifier=saveclassifier('svm',options.Kernel,options.KernelParam,...
%    alpha,X(svs+1,:),b,options);
%classifier.svs=svs+1;
