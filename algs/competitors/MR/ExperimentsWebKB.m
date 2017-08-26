function [prbep_svm,prbep_rlsc]=ExperimentsWebKB(mode,joint)

%% For binary classification on LINK.mat PAGE.mat PAGE+LINK.mat 
%% mode='link' | 'page' | 'page+link' 
%% link=0 or 1. Put 1 if you want to use a 
%% joint regularizer (multi-view learning). Otherwise ignore this argument or put joint=0.
%% e.g [prbep_svm,prbep_rlsc]=ExperimentsWebKB('link') 
%% or [prbep_svm,prbep_rlsc]=ExperimentsWebKB('link',1)
%% options are in the mat file %%
%%
%% Returns the PRBEP performance over the 100 splits
%%

if ~exist('joint','var')
   joint=0; 
end
if joint==1
    load LINK.mat; L1=laplacian(options,X);
    load PAGE.mat; L2=laplacian(options,X);
    load PAGELINK.mat; L3=laplacian(options,X);
    options.gamma_A=0.01; options.gamma_I=0.1;
    L=(L1+L2+L3)/3; 
    clear L1 L2  L3;
end



switch mode

case 'link'
    load LINK.mat;
case 'page'
    load PAGE.mat
case 'page+link'
    load PAGELINK.mat
end

if joint==0
    L=laplacian(options,X);
end


tic;

% construct the semi-supervised kernel by deforming a linear kernel with
% the graph regularizer
% K contains the gram matrix of the new data-dependent semi-supervised kernel
K=Deform(options.gamma_I/options.gamma_A,calckernel(options,X),L^options.LaplacianDegree);

% run over the random splits
for R=1:size(idxLabs,1)

	L=idxLabs(R,:); U=1:size(K,1); U(L)=[];
	data.K=K(L,L); data.X=X(L,:); data.Y=Y(L); % labeled data
 
	classifier_svm=svm(options,data);
	classifier_rlsc=rlsc(options,data);

	testdata.K=K(U,L);
  
	prbep_svm(R)=test_prbep(classifier_svm,testdata.K,Y(U));
        prbep_rlsc(R)=test_prbep(classifier_rlsc,testdata.K,Y(U));
 
disp(['Laplacian SVM Performance on split ' num2str(R) ': ' num2str(prbep_svm(R))]);
disp(['Laplacian RLS Performance on split ' num2str(R) ': ' num2str(prbep_rlsc(R))]);

end
fprintf(1,'\n\n');  
disp(['Mean (std dev) Laplacian SVM PRBEP :  ' num2str(mean(prbep_svm))  '  ( ' num2str(std(prbep_svm))  ' )']);
disp(['Mean (std dev) Laplacian RLS PRBEP  ' num2str(mean(prbep_rlsc)) '  ( ' num2str(std(prbep_rlsc)) ' )']);

 

function prbep=test_prbep(classifier,K,Y);
   f=K(:,classifier.svs)*classifier.alpha-classifier.b;
   [m,n,maxcm]=classifier_evaluation(f,Y,'pre_rec_equal');
   prbep=100*(maxcm(1,1)/(maxcm(1,1)+maxcm(1,2)));

