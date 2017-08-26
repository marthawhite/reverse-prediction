class_opts = [];
class_opts.verbose = 0;

filesuffix = 'euclidean13';

class_opts.tl = 10;
class_opts.num_repetitions = 100;
class_opts.output_file = ['results/results_script_semisup_class_' filesuffix];

class_opts.DataNames = {'Gaussian-Class'};

% Default algorithms and transfers
class_opts.AlgNames = {'LinearSupervisedClass','LinearSupervisedNCut','LinearSemiSupervisedClass',...
                    'LinearSemiSupervisedNCut', 'SemiZhou','SemiLapSVM','SemiLapRLSC'};

class_opts.TransferNames = {'Euclidean','Sigmoid','Softmax','WEuclidean','WSigmoid','WSoftmax'};
class_opts.TransferAlgs = {'KmeansBregman', 'EmBregman', 'KmeansBregmanSemi','EmBregmanSemi', 'EmBregmanSemiNormCut'};

% Recover models; not useful as competitors all transductive
class_opts.recover = 0;

% Lets cross-validate
class_opts.cross_validate = 2;

results = run_semisup(class_opts);

save(['results/results_class_' filesuffix '.mat'], 'results');
printLatexTable(results);


