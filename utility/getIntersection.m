function [intersection, rest] = getIntersection(set1,set2)
    
intersection = {};
rest = {};

for i = 1:length(set1)
   tempind = find(ismember(set2,set1{i}) == 1);
   if ~isempty(tempind)
      intersection = [intersection {set1{i}}];
   else
      rest = [rest {set1{i}}];
   end    
end   
 
end

