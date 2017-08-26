function results = run_semisup(opts)
% Note that defaults for run_semisup runs a large classification experiment
  
  initialize_matlab();

  % Parameters for data set size and repetitions
  DEFAULTS.tl = 20;
  DEFAULTS.tt = 1000;
  DEFAULTS.num_repetitions = 5;

  % Parameters for cross validation
  % Want the error function to round the predicted value for classification
  DEFAULTS.error_fcn = @(Yactual, Yhat)(classify_error(Yactual,roundY(Yhat)));
  DEFAULTS.num_folds = 5;
  DEFAULTS.cross_validate = 0;    % = 0 use default params
                                  % = 1 cross validate over reduced set in getParameters
                                  % = 2 cross validate over extensive set in getParameters
                                  % = 3 pick best over reduced set in getParameters using test error
                                  % = 4 pick best over extensive set in getParameters using test error
  DEFAULTS.parameters = {};
  DEFAULTS.compute_lots = 0;

  % Input and output files
  DEFAULTS.output_file = ['../../results/output_script_semisup_class_' date];
  DEFAULTS.DataNames = {'Gaussian-Class', 'Sigmoid', 'Softmax', 'Set1', 'Set3', 'Set5','Set8'};

  % Default algorithms and transfers
  DEFAULTS.AlgNames = {'LinearSupervisedClass','LinearSupervisedNCut','LinearSemiSupervisedClass',...
                      'LinearSemiSupervisedNCut', 'SemiZhou','SemiLapSVM','SemiLapRLSC'};
  DEFAULTS.TransferNames = {'Euclidean','Sigmoid','Softmax','WSigmoid'};
  DEFAULTS.TransferAlgs = {'KmeansBregmanSemi','EmBregmanSemi', 'EmBregmanSemiNormCut'};

  DEFAULTS.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
  DEFAULTS.verbose = 0;	% 0 gives no warning statements, 
                        % 1 prints warnings
                        % 2: print out optimization statements, with warnings
                        % 3: print out optimization statements, but no warning
  if nargin < 1
    opts = DEFAULTS;
  else
    opts = getOptions(opts, DEFAULTS);
  end

  if opts.verbose == 0 || opts.verbose == 3
    warning off all;
  else
    warning on all;
  end    
  if opts.recover == 0
    opts.tt = 0;
  end

  numDG = length(opts.DataNames);
  [n_data, k_data, tu_data, dataLoaders, filenames] = getDataInfo(opts.DataNames);

  % Initialize the parameters for each dataset
  % Specify transfer functions and other algorithms to run 
  % If parameters given, then do not extend algorithms set
  if isempty(opts.parameters)
    AugAlgNames = extendAlgNames(opts.TransferAlgs, opts.TransferNames);
    opts.AlgNames = [opts.AlgNames AugAlgNames];        
    opts.parameters = cell(numDG);
    if opts.cross_validate > 2
        AllParams = getParameters(opts.AlgNames, opts.cross_validate-2); 
    else
        AllParams = getParameters(opts.AlgNames, opts.cross_validate); 
    end    
    if (length(opts.AlgNames) ~= length(AllParams))
      error('script_semisup_class -> Different number of algorithms and parameter options!');
    end      
    for dg = 1:numDG
      opts.parameters{dg} = AllParams;
    end
  else
    opts.cross_validate = 0;
  end

  % Get algorithm functions
  Algs = getAlgs(opts.AlgNames);
  numAlgs = length(opts.AlgNames);

  % Contains misclass_train, objective, diff due to reverse model, misclass_test
  TRAIN_ERROR = 1; TEST_ERROR = 2; COMPARISON_INDEX = 1;
  if opts.recover == 0
    errorNames = {'Training Error'};
  else
    errorNames = {'Training Error','Testing Error'};
  end
  numErrors = length(errorNames);

  totalErr = zeros(numDG,numAlgs,numErrors,opts.num_repetitions);
  summedErr = zeros(numDG,numAlgs,numErrors);
  summedErr_std = zeros(numDG,numAlgs,numErrors);
  bestParams = cell(numDG);
  
  % Overwrite file to print to it
  [fileId, message] = fopen(opts.output_file, 'w');
  if (~isempty(message))
    fileId = 1;
  end    
  if (fileId ~= 1)
    fclose(fileId);
    fileId = 0;
  end    
  
  for dg = 1:numDG   
    for reps = 1:opts.num_repetitions
      fprintf(1, 'Running with tu = %g, tl= %g, n = %g, k = %g, rep=%u on dataset %s...\n',...
              tu_data(dg),opts.tl, n_data(dg),k_data(dg),reps,opts.DataNames{dg});
      
      [Xl,Yl,Xu,Yu,Xtest,Ytest] = feval(dataLoaders{dg},opts.tl,tu_data(dg),opts.tt,reps);
      
      for a = 1:numAlgs
        if opts.verbose > 0
          fprintf(1, 'Running algorithm %s...\n', opts.AlgNames{a});
        end
        % Weird sizes here so that below can add with totalErrs
        minErrs = Inf*ones(1,1,numErrors); 
        errors = zeros(1,1,numErrors);
        algFcn = Algs{a};
        
        if (reps == 1 && (opts.cross_validate==1 || opts.cross_validate==2))
          % Cross validate to get the best parameters
          [best_index,best_params] = crossValidate(opts.parameters{dg}{a},algFcn,Xl,Yl,Xu,[],opts);
          opts.parameters{dg}{a} = {opts.parameters{dg}{a}{best_index}};
          fprintf(1, 'CV param index for %s: %u\n', opts.AlgNames{a}, best_index);
        end
        
        bestparamind = -1;
        for o = 1:length(opts.parameters{dg}{a})
          algopts = opts.parameters{dg}{a}{o};
          algopts.verbose = opts.verbose;
          algopts.compute_lots = opts.compute_lots;
          if opts.recover == 1 && nargout(algFcn) >= 3
            [Yhat,What,Uhat] = algFcn(Xl,Yl,Xu,algopts);
            errors(TEST_ERROR) = opts.error_fcn(Ytest,getPrediction(opts.AlgNames{a},algopts,Xl,Yl,Xu,Xtest,What));
          else
            Yhat = algFcn(Xl,Yl,Xu,algopts);
            
            if opts.recover == 1
              errors(TEST_ERROR) = -1;      
            end
          end
          
          % Get missclassifcation error of Y from clustering algorithm
          errors(TRAIN_ERROR) = opts.error_fcn(Yu,Yhat);
          
          if  minErrs(COMPARISON_INDEX) > errors(COMPARISON_INDEX) 
            minErrs = errors;
            bestparamind = o;
          end    
        end	
        totalErr(dg,a,:,reps) = minErrs;
        totalErr_sq(dg,a,:,reps) = minErrs.^2;
        if opts.cross_validate > 2
          fprintf(1, 'Best param index for %s: %u\n', opts.AlgNames{a}, bestparamind);
        end 
        if bestparamind == -1
            bestParams{dg}{a} = {[]};
        else
            bestParams{dg}{a} = {opts.parameters{dg}{a}{bestparamind}};
        end
      end    
    end	
    % Compute mean and compute error bars, i.e. divide by sqrt(N)
    summedErr(dg,:,:) = sum(totalErr(dg,:,:,:),4)/opts.num_repetitions;
    summedErr_std(dg,:,:) = sqrt(sum(totalErr_sq(dg,:,:,:),4)/opts.num_repetitions - ...
                                 summedErr(dg,:,:).^2);
    
    if (fileId ~= 1) 
      fileId = fopen(opts.output_file, 'a');
    end
    fprintf(1,'Printing results to %s....\n',opts.output_file);			    
    fprintf(fileId,['***************** Results for %s data ' ...
                    '*******************\n\n\n'],opts.DataNames{dg});
    for i = 1:numErrors
      fprintf(fileId, '\t\t\t\t %s ', errorNames{i});
    end
    fprintf(fileId,'\n\n');
    for a = 1:numAlgs
      fprintf(fileId, '%s : ', opts.AlgNames{a});
      for i = 1:numErrors
        fprintf(fileId, '\t\t\t %g +- %g',summedErr(dg,a,i), summedErr_std(dg,a,i)/sqrt(opts.num_repetitions));
      end
      fprintf(fileId,'\n\n');
    end
    
    if (fileId ~= 1)
      fclose(fileId);
    end
  end

  % Return results struct
  results = [];
  results.opts = opts;
  results.totalErr = totalErr;
  results.summedErr = summedErr;
  results.summedErr_std = summedErr_std;
  results.bestParams = bestParams;
  results.filenames = filenames;
end








