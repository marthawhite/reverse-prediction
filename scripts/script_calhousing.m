
regression_opts = [];
regression_opts.error_fcn = @regression_error;
regression_opts.cross_validate = 0; % = 1 cross validate over reduced set of params in getParameters
regression_opts.num_repetitions = 100;
regression_opts.tl = 20;

regression_opts.output_file = ['results_script_semisup_regression_calhousing4'];
regression_opts.DataNames = {'CalHousing'};

% Default algorithms and transfers
regression_opts.AlgNames = {'LinearSupervisedReg','LinearSemiSupervisedReg','SemiLapRLS','TRG'};
regression_opts.TransferNames = {'Euclidean','Exp', 'Cube', 'WEuclidean'};
regression_opts.TransferAlgs = {'Regression', 'RegressionSemi'};

regression_opts.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
regression_opts.verbose = 0;	% 0 gives no warning statements
regression_opts.compute_lots = 1;	

results = run_semisup(regression_opts);

save('results/results_regression_calhousing4.mat', 'results');
printLatexTable(results,1,1);

