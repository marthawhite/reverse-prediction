function AllParams = getParameters(algNames, setting)
% Returs an array of parameter values for the given algNames
% Setting can be:
%   0 -- returns a single default set of parameters
%   1 -- returns a reduced set of cross-wise products of parameters  
%   2 -- returns the most extensive cross-wise products of parameters  
% DEFAULT: setting = 0 (optional parameter)
%
% Author: Martha White, University of Alberta, 2012

  if nargin < 2
    setting = 0; 
  end  
  if setting == 0
    mus = 0.1; betas = 1e-1; rhos = 1; kernels = {@kernel_linear}; kernels_ncut = {@kernel_linear};
    widths = 0.1; NNs = 10; degrees = 1;
    mus = 0;
  elseif setting == 1   
    %mus = [1e-3 0.1 1];
    mus = [0.1 1];
    betas = [1e-3 1e-2 1e-1 1];    
    rhos = [1e-3 0.1];  % Only for a certain clustering algorithm
    NNs = [1 5 10];  % Only for SemiLapSVM
    degrees = [1 2 5];  % Only for SemiLapSVM   
    kernels = {@kernel_noop, @kernel_linear};
    kernels_ncut = {@kernel_linear}; 
  else 
    mus = [1e-3 1e-2 0.1 1];
    betas = [1e-4 1e-3 1e-2 1e-1 1];  
    rhos = [1e-5 1e-3 0.1 0.5];
    NNs = [1 5 10 20]; 
    degrees = [1 2 5];    
    %widths = [1e-2 0.1 0.5 1 5 10];
    widths = [0.1 1];
    kernels = {@kernel_noop, @kernel_linear};
    kernels_ncut = {@kernel_linear};
    for w = widths
	    kernels = [kernels {@(X1,X2)(kernel_rbf(X1,X2,w))}];
	    kernels_ncut = [kernels_ncut {@(X1,X2)(kernel_rbf(X1,X2,w))}];
    end  
  end

  numKernels = length(kernels);
  numKernelsNCut = length(kernels_ncut);
  numAlgs = length(algNames);
  AllParams = []; 

  for ii = 1:numAlgs

    %%%%%%%%%%%%%%%%%%%% THE SUPERVISED CLASSIFICATION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmp(algNames{ii}, 'SVM')          % Get SVM function
      params = [];
      opts = [];
      for alpha = betas
        opts.alpha = alpha;
        params = [params {opts}];
      end    
      AllParams = [AllParams {params}];

    elseif strcmp(algNames{ii}, 'LinearSupervisedClass')   
      params = [];
      opts = [];
      for beta = betas
        for k = 1:numKernels
          opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k};
          params = [params {opts}];
        end
      end    
      AllParams = [AllParams {params}];

    elseif strcmp(algNames{ii}, 'LinearSupervisedNCut') 
      params = [];
      opts = [];
      for beta = betas
        for k = 1:numKernelsNCut
          opts.alpha = beta; opts.beta = beta; opts.kernel = kernels_ncut{k};
          params = [params {opts}];
        end
      end    
      AllParams = [AllParams {params}]; 
      
    elseif isempty(strfind(algNames{ii}, 'Semi')) && ...
          strncmp(algNames{ii}, 'EmBregman', length('EmBregman'))         
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for beta = betas
        for rho = rhos
          for k = 1:numKernels
            opts.alpha = beta; opts.beta = beta; opts.rho = rho; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end    
        end
      end
      AllParams = [AllParams {params}];
      
    elseif isempty(strfind(algNames{ii}, 'Semi')) && ...
          strncmp(algNames{ii}, 'KmeansBregman', length('KmeansBregman'))         
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for beta = betas
        for k = 1:numKernels
          opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
          params = [params {opts}];
        end
      end
      AllParams = [AllParams {params}];
      
      %%%%%%%%%%%%%%%%%%%% THE SEMISUPERVISED CLASSIFICATION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%
      
    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedClass')   
      params = [];
      opts = [];
      for mu = mus
        for beta = betas
          for k = 1:numKernels
            opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];

    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedNCut') 
      params = [];
      opts = [];
      for mu = mus
        for beta = betas
          for k = 1:numKernelsNCut
            opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.kernel = kernels_ncut{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];
      
    elseif strncmp(algNames{ii}, 'KmeansBregmanSemi', length('KmeansBregmanSemi'))
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for mu = mus
        for beta = betas
          for k = 1:numKernels
            opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];
      
    elseif strncmp(algNames{ii}, 'EmBregmanSemi', length('EmBregmanSemi'))  
      %rhosEm = [20 100 500];
      rhosEm = rhos;
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for mu = mus
        for beta = betas
          for rho = rhosEm
            for k = 1:numKernels
              opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.rho = rho; opts.kernel = kernels{k}; 
              params = [params {opts}];
            end  
          end    
        end
      end
      AllParams = [AllParams {params}];              

    elseif strncmp(algNames{ii}, 'EmBregmanSemiNormCut', length('EmBregmanSemiNormCut'))         
      %rhosEm = [20 100 500];
      rhosEm = rhos;
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      opts.lambda = -1;
      for mu = mus
        for beta = betas
          for rho = rhosEm
            for k = 1:numKernelsNCut
              opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.rho = rho; opts.kernel = kernels_ncut{k}; 
              params = [params {opts}];
            end  
          end    
        end
      end
      AllParams = [AllParams {params}]; 
      
    elseif strcmp(algNames{ii}, 'SemiZhou') 
      params = [];
      opts = [];
      for alpha = betas
        for k = 1:numKernelsNCut
          opts.alpha = alpha; opts.kernel = kernels_ncut{k}; 
          params = [params {opts}];
        end
      end
      AllParams = [AllParams {params}];

    elseif strcmp(algNames{ii}, 'SemiLapSVM') || strcmp(algNames{ii}, 'SemiLapRLSC')
      params = [];
      opts = [];
      for nn = NNs
        for degree = degrees
          opts.NN = nn; opts.degree = degree; opts.width = -1;
          params = [params {opts}];
          for width = widths
            opts.NN = nn; opts.degree = degree; opts.width = width;
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];
      

      %%%%%%%%%%%%%%%%%%%% THE SUPERVISED REGRESSION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(algNames{ii}, 'LinearSupervisedReg')         
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for beta = betas
        for k = 1:numKernels
          opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
          params = [params {opts}];
        end
      end
      AllParams = [AllParams {params}]; 
      
    elseif isempty(strfind(algNames{ii}, 'Semi')) && strncmp(algNames{ii}, 'Regression', length('Regression'))         
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for beta = betas
        for k = 1:numKernels
          opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
          params = [params {opts}];
        end
      end
      AllParams = [AllParams {params}];
      
      %%%%%%%%%%%%%%%%%%%% THE SEMISUPERVISED REGRESSION ALGORITHMS %%%%%%%%%%%%%%%%%%%%%%%%%
      
    elseif strcmp(algNames{ii}, 'LinearSemiSupervisedReg')         
      params = [];
      opts = [];
      for mu = mus
        for beta = betas
          for k = 1:numKernels
            opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];

    elseif strncmp(algNames{ii}, 'RegressionSemi', length('RegressionSemi'))         
      params = [];
      opts = [];
      opts.transfer = extractTransfer(algNames{ii});
      for mu = mus
        for beta = betas
          for k = 1:numKernels
            opts.mu = mu; opts.alpha = beta; opts.beta = beta; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];
      
    elseif strcmp(algNames{ii}, 'SemiLapRLS')         
      gammaIs = [1e-4 1e-3 1e-2];
      gammaAs = [1e-2 1e-1 1 2];
      params = [];
      opts = [];
      for gammaI = gammaIs
        for gammaA = gammaAs
          for k = 1:numKernelsNCut
            opts.gamma_I = gammaI;  opts.gamma_A = gammaA; opts.kernel = kernels_ncut{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}];
      
    elseif strcmp(algNames{ii}, 'TRG')         
      C1s = [1 2 5 10];
      C2s = [1 2 5 10];
      params = [];
      opts = [];    
      for C1 = C1s
        for C2 = C2s
          for k = 1:numKernels
            opts.C1 = C1;  opts.C2 = C2; opts.kernel = kernels{k}; 
            params = [params {opts}];
          end
        end
      end
      AllParams = [AllParams {params}]; 

    else
      error(['getAlgs -> Cannot currently handle ' algNames{ii} ' must use ' ...
             'predefined algorithms']);
    end

  end


end
