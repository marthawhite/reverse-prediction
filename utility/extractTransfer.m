function transfer = extractTransfer(string)
% Finds which transfer is given within the algorithm name
%
% Author: Martha White, University of Alberta, 2012

    transfer = [];
    if ~isempty(strfind(string, 'Euclidean')) || ~isempty(strfind(string, 'Linear'))
        transfer = 'Euclidean';
        
    elseif strfind(string, 'Sigmoid')
        transfer = 'Sigmoid';
        
    elseif strfind(string, 'Softmax')
        transfer = 'Softmax';

    elseif strfind(string, 'SSigmoid')
        transfer = 'SSigmoid';

    elseif strfind(string, 'WSigmoid')
        transfer = 'WSigmoid';

    elseif strfind(string, 'Exp')
        transfer = 'Exp';
   
    elseif strfind(string, 'Log')
        transfer = 'Log';

    elseif strfind(string, 'Cube')
        transfer = 'Cube';

    elseif strfind(string, 'CollinsCube')
        transfer = 'CollinsCube';
 
    else
        error(['Invalid loss name, cannot currently handle transfer given in algName: ' string]);
    end      
end
