
regression_opts = [];
regression_opts.error_fcn = @regression_error;
regression_opts.cross_validate = 2; % = 1 cross validate over params in getParameters
regression_opts.num_repetitions = 100;
regression_opts.tl = 10;
regression_opts.compute_lots = 1;

% Can run on multiple data files
%regression_opts.DataNames = {'Gaussian-Reg', 'Cube', 'Exp', 'Kin32fh', 'Pumadyn8fh', 'CalHousing','Pumadyn8nm'};
regression_opts.DataNames = {'Kin32fh'};

filesuffix = 'kin32fh';
regression_opts.output_file = ['results_script_semisup_regression_' filesuffix];

% Default algorithms and transfers
regression_opts.AlgNames = {'LinearSupervisedReg','LinearSemiSupervisedReg','SemiLapRLS','TRG'};
regression_opts.TransferNames = {'Euclidean', 'Exp', 'Cube'};
regression_opts.TransferAlgs = {'Regression', 'RegressionSemi'};

regression_opts.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
regression_opts.verbose = 0;	% 0 gives no warning statements
                              %regression_opts.compute_lots = 1;	% 0 gives no warning statements

results = run_semisup(regression_opts);
results.date = date;

save(['results/results_regression_' filesuffix '.mat'], 'results');
printLatexTable(results);

