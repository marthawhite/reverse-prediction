README


*****************************
To get started:

You can simply go to the directory script and run script_semisup_class.m or script_semisup_regression.m. This runs the classification algorithms (or regression algorithms) on the a provided real data set.

To run the algorithms on synthetic data, you will need to generate it in the data directory and change what synthetic data files are being used. Synthetic files are not provided to make the distribution smaller. To generate synthetic data, go to data/generateSynthetic.m and change the options, to generate data with different dimensions, noise, etc. To use the generated datasets in script_semisup_regression, change the name of the file in data/getDataInfo.m. In script_semisup_regression, you can change the desired regression_opts.DataNames to the synthetic data file.

Each of the desired algorithms and datasets are specified in script_semisup_class and script_semisup_regression.m. You do not really need to understand the rest of the files. Each of these scripts calls run_semisup.m with the parameters specified.


****************************
More details:

This package contains the generalized reverse prediction framework, as well as competitors. The main scripts for classification and regression are in scripts/. The main file used by scipt_semisup_regression.m and script_semisup_class.m is run_semisup.m, which requires parameters to specify the experiment. The default parameters in run_semisup run a classification experiment (i.e. if run_semisup() is called). See how script_semisup_regression.m currently sets the parameters for a regression experiment and to see how to change the number of training samples, what algorithms to run, what datasets to use and other experiment parameters.

This package also contains the original linear reverse prediction framework (where the kernelization was implemented slightly differently). The directories are as follows
with an explanation of their content:

algs:
	Contains all of our reverse prediction algorithms (including the previous linear implementations in sub-directory linear-algs). Competitors
are also included. NOTE: MR was obtained from http://manifold.cs.uchicago.edu/manifold_regularization/manifold.html

The most important function in this directory is getAlgs(AlgNames), which returns an array of fcn(Xl,Yl,Xu,opts) based on the named algorithms provided
e.g. AlgNames = {'SupervisedClass', 'SemiZhou', 'clusterEmBregmanSemi'};

Note that the opts can be set to change the kernel and other parameters, as every learning function has the form:
	function [Z,W,U,flag] = algorithm_name(Xlabel,Ylabel,Xunlabel,opts)
where opts contains several options for the algorithm, like kernel, optimization tolerance, etc. Each algorithm has a list of DEFAULTS at the top of the file specifying the possible options. Note that this options may NOT be complete, as the options can then be further passed to a sub function (such as fmin_LBFGS). For the algorithms, however, currently they are a complete set. Note that the only place where the DEFAULT options specified at the top of a file are not complete is fmin_LBFGS: it passes its own options to backtrack, which could include opts.Apd and opts.bpd which backtrack uses but fmin_LBFGS does not.

getParameters(AlgNames) returns a possible set of parameters for each algorithm (over which the algorithms can be cross-validated) or
getParameters(AlgNames, 1) returns a default set of parameters
e.g. getParameters({'LinearSupervisedClass', 'SemiZhou', 'clusterEmBregmanSemi'}) = 
{ // For LinearSupervisedClass, beta in {0.1, 0.5}, kernel in {@kernel_noop}
	{struct('beta', 0.1, 'kernel', @kernel_noop),
	 struct('beta', 0.5, 'kernel', @kernel_noop)},
// For SemiZhou alpha in {0.1, 0.5}, kernel in {@kernel_noop, @kernel_linear}
	{struct('alpha', 0.1, 'kernel', @kernel_noop),
	 struct('alpha', 0.1, 'kernel', @kernel_linear),
	 struct('alpha', 0.5, 'kernel', @kernel_noop),
	 struct('alpha', 0.5, 'kernel', @kernel_linear)}
}

competitors:

The competitors require libsvm and their manifold regression packages. They are included with the distribution for ease of use, but note that all the copyright that they specify pertains and to acknowledge their code also when it is used. 

loss:
	Contains all the loss functions and transfer function information. The loss functions might require a constrained optimization. This is achieved by outputting a struct with constraint matrices A, b and/or Aeq, beq. For an example, see Lrev_exp or Lfor_log:
	function [f,g,constraint_opts] = Lfor_log(X,W,Y)
fmin_LBFGS checks for this output and constrains the optimization if the constraint matrices are given. The loss functions only compute the variables if they are required (i.e. based on nargout): g and constraint_opts are not computed needlessly.

Note that sometimes the constraints are computed each time the function is called, because they are dependent on changing parameters. Some constraints, however, are variable independent: persistent variables are used to avoid recomputing the constraint matrices each time.

data:
	Contains several datasets, including functionality to generate new synthetic datasets. The file saveSplit generates new datasets for generation functions and other parameters. getDataInfo gets information about each dataset, including n, k, etc. This set-up allows the same datasets to be loaded each time, even in the case of synthetic data (to allow repeatable tests).

solvers:
	Contains optimization algorithms used by the algorithms in algs/. The LBFGS code is implemented by the Machine Learning group at the University of Alberta. The libsvm package is obtained from FINISH.

Somewhat annoyingly, to get the MEX files to compile on a Mac, you have to be careful about the SDK information in the mexopts.sh file. To ensure this is correct, generate the mexopts.sh by typing in matlab (in the libsvm folder):
> mex -setup
Choose compiler 1. Then type make. If this does not work, then the mexopts.sh file is being generated incorrectly. To fix this, edit you mexopts.sh (the path was specified in the mex -setup phase), on line 167 change the OS number to the correct one (e.g. 10.6 to 10.7).

utility:
	Extra utility functions, e.g. reading options, printing to latex tables.
