function saveSplit(opts)

global data_dir;

DEFAULTS.tl = 100;
DEFAULTS.tu = 4900;
DEFAULTS.n = 30;
DEFAULTS.k = 5;
DEFAULTS.sigma = 0.1;

DEFAULTS.numSplits = 20;
DEFAULTS.gen = @genRevGaussian;
DEFAULTS.name = 'gaussian-reg';

if nargin < 1
    opts = DEFAULTS;
else
    opts = getOptions(opts, DEFAULTS);
end

% Only genRevGaussian uses opts.gen_reals
if strcmp(opts.name,'gaussian-reg') 
    opts.gen_reals = 1;
else    
    opts.gen_reals = 0;
end

% TODO: for classification, split training and testing evenly for classes 
opts.t = opts.tl+opts.tu;
X = [];
Y = [];
actualModels = {};
idxLabs = [];
idxUnlabs = [];
filename = [opts.name ',n=' int2str(opts.n) ',k=' int2str(opts.k) ',sigma=' num2str(opts.sigma) ...
            ',t=' int2str(opts.t) ',labeled=' int2str(opts.tl) '.mat'];

for i = 1:opts.numSplits
    [X_c,Y_c, model] = opts.gen(opts.t, opts.n, opts.k);
    X = [X ; X_c];
    Y = [Y; Y_c];
    actualModels = [actualModels {model}];
    start = length(idxLabs)+1;
    idxLabs = [idxLabs; start:(start+opts.tl-1)];
    idxUnlabs = [idxUnlabs; (start+opts.tl):(start+opts.t-1)];
end

save([data_dir '/synthetic/' filename],'X','Y', 'actualModels', ...
     'idxLabs','idxUnlabs');



