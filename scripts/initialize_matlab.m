function [] = initialize_matlab ()

global proj_dir;
global code_dir;
global data_dir;

cd ..;
proj_dir = pwd;
cd scripts;

% Add matlab solvers and loss
code_dir = proj_dir;

addpath(code_dir);
addpath([code_dir '/algs']);
addpath([code_dir '/algs/linear-algs']);
addpath([code_dir '/algs/competitors']);
%addpath([code_dir '/algs/competitors/MR']);
addpath([code_dir '/loss']);
addpath([code_dir '/loss/potentialfcns']);
addpath([code_dir '/scripts']);
addpath([code_dir '/solvers']);
addpath([code_dir '/solvers/lbfgs']);
addpath([code_dir '/solvers/libsvm']);
addpath([code_dir '/solvers/libsvm/matlab']);
addpath([code_dir '/utility']);
addpath([code_dir '/data']);


% Specify the path to the data
data_dir = [proj_dir '/data'];


