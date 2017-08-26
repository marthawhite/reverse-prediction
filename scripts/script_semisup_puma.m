
regression_opts = [];
regression_opts.error_fcn = @regression_error;
regression_opts.cross_validate = 1; % = 1 cross validate over params in getParameters
regression_opts.num_repetitions = 50;

regression_opts.output_file = ['results_script_semisup_regression_pumafh'];
regression_opts.DataNames = {'Pumadyn8fh'};

% Default algorithms and transfers
regression_opts.AlgNames = {'LinearSupervisedReg','LinearSemiSupervisedReg','SemiLapRLS','TRG'};
regression_opts.TransferNames = {'Euclidean','Exp','Softmax', 'Cube'};
regression_opts.TransferAlgs = {'Regression', 'RegressionSemi'};

regression_opts.recover = 0;   % Recover the models F and B; in this case, f_inv must be defined
regression_opts.verbose = 0;	% 0 gives no warning statements


results = run_semisup(regression_opts);

save('results/results_regression_pumadyn8fh.mat', 'results');
printLatexTable(results);

