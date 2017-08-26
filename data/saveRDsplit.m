function saveRDsplit(dataname, newname, numreps, tl, tu)
% Writes to dataname-splits

load(dataname);

% Saves numreps random subsets of the data
idxLabs = zeros(numreps,tl);
idxUnls = zeros(numreps,tu);
t = size(X,1);

for i = 1:numreps
    indices = randperm(t);
    idxLabs(i,:) = indices(1:tl);
    idxUnls(i,:) = indices((tl+1):(tl+tu));
end

X = normalizeMatrix(X);

save(newname,'X','Y','idxLabs','idxUnls');



