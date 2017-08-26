function ind = isSubset(name, allNames)
    
 ind = -1;
 if ~iscell(name)
    ind = find(ismember(allNames,name) == 1);
 else
     for i = 1:length(name)
        tempind = find(ismember(allNames,name{i}) == 1);
        if isempty(tempind)
            return;
        end    
     end   
 end
 
end

