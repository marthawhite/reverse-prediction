function [Xl,Yl,Xu,Yu,Xtest,Ytest] = loadData(dataName,dataIndices,tl,tu,tt,rep,is_class)
% Adjusts any classification data
% Normalizes data
    
global data_dir;

if nargin < 7
    is_class = 0;    
end

% Clear any variables ahead of time so can overwrite them
if exist('X','var'), clear X; end
if exist('T','var'), clear T; end
if exist('Y','var'), clear Y; end
if exist('y','var'), clear y; end
if exist('idxLabs','var'), clear idxLabs; end
if exist('idxUnls','var'), clear idxUnls; end
if exist('idxUnlabs','var'), clear idxUnlabs; end

load([data_dir dataName]);
if ~isempty(dataIndices)
    load([data_dir dataIndices]);
end

if ~exist('idxUnls','var')
    idxUnls = idxUnlabs;
end

if (rep > size(idxUnls,1))
    warning(['Only has %u splits, cannot return split for %u. Returning' ...
                'moded split...'],size(idxUnls,1),rep);
    rep = mod(rep-1,size(idxUnls,1))+1;
end    

% Some datasets have T instead of X
if ~exist('X','var')
  X = T;
end
X = normalizeMatrix(X);
if ~exist('y','var')
    y = Y;
end
[t,k] = size(y);
Y = y;

% If tl > size(Xl,1), then take some data from Xu
Xl = X(idxLabs(rep,:),:);
Xu = X(idxUnls(rep,:),:);
Yl = Y(idxLabs(rep,:),:);
Yu = Y(idxUnls(rep,:),:);

% If classification data stored as 1-dim array as {1,-1} or
% as {1,2,3,...,k}, convert to binary k-dim array.
if is_class && k == 1
    Ycat = [Yl;Yu];
    k = length(unique(Ycat));
    Ycat2 = zeros(size(Ycat,1), k);
    % Check first if using indexing 1:k
    if k > 2
        for i = 1:k
            Ycat2(Ycat == i,i) = 1;
        end   
    else    
        Ycat2(Ycat == 1,1) = 1;
        Ycat2(Ycat ~= 1,2) = 1;
    end
    Yl = Ycat2(1:size(Yl,1), :);
    Yu = Ycat2(size(Yl,1)+1:end, :);
end

% If requesting more labeled samples than in labeled Yl, must take
% from unlabeled matrix. Try to make sure at least one sample from
% each class
diff = tl - size(Xl,1);
if diff > 0
    Xl = [Xl; Xu(1:diff,:)];
    Yl = [Yl; Yu(1:diff,:)];      
else
    tl_indices = [];
    if is_class == 0
        tl_indices = 1:tl;
    else
    	classIndices = cell(k);
    	for i = 1:size(Yl,1)
    	    class = find(Yl(i, :));
    	    classIndices{class} = [classIndices{class} i];
    	end    
    	index = 1; tl_indices = [];
    	while length(tl_indices) < tl
    	  for i = 1:k
    	     if length(classIndices{i}) >= index
    	        tl_indices = [tl_indices classIndices{i}(index)]; 
    	     end 
    	  end
    	  index = index + 1;
    	end
    	tl_indices = tl_indices(1:tl);
    end
    Xl = Xl(tl_indices,:);
    Yl = Yl(tl_indices,:);    
end

% Determine the indices for the unlabeled data, as some of it may have
% been used as labeled data
unlabeledStartIndex = 1;
unlabeledEndIndex = tu;
if diff > 0 && (tu+diff < size(Xu,1))
    unlabeledStartIndex = diff+1;
    unlabeledEndIndex = tu+diff;
end

% Finally, use the remaining data (up to tt) for test data.
testEndIndex = min(size(Xu, 1), unlabeledEndIndex + tt);
Xtest = Xu((unlabeledEndIndex+1):testEndIndex, :);
Ytest = Yu((unlabeledEndIndex+1):testEndIndex, :);
Xu = Xu(unlabeledStartIndex:unlabeledEndIndex,:);
Yu = Yu(unlabeledStartIndex:unlabeledEndIndex,:);

end

