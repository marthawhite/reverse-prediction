function classifier=saveclassifier(name,svs,alpha,xtrain,b,options)

% SAVECLASSIFIER Generates a data structure containing 
%                details of a kernel classifier
%
%
% classifier=saveclassifier(name,alpha,xtrain,bias,lambda)
%
% Inputs: A kernel classifier is of the form 
%			sign(sum_i alpha_i  K(x_i,x) - b)
%
% 
% svs -- indices of training data in the sum sum_i
% alpha -- A Lx1 coefficient vector
% xtrain -- corresponding training examples
% b -- bias 
% options -- the options data structure used to make the classifier
%            this contains the regularization parameters, kernel 
%	     function, kernel parameters etc. 
%
% Output:
%
% classifier -- a data structure with the following fields :
% 
% classifier.Name=name;  -- name of the classifier
% classifier.alpha=alpha; -- expansion coefficients 
% 				(weights for linear machines)
% classifier.b=b; -- bias
% classifier.xtrain=xtrain; -- vectors correponding to the coefficients
% classifier.options=options;
% classifier.svs = indices of training data in the expansion
%
%  Author: 
%         Vikas Sindhwani (vikass@cs.uchicago.edu)

classifier.Name=name;
classifier.svs=svs;
classifier.alpha=alpha; % is the weight vector for linear_lapsvm/linear_laprlsc 
classifier.b=b;
classifier.xtrain=xtrain; % is [] for linear_lapsvm/linear_laprlsc
classifier.options=options;
