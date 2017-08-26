function printLatexTable(results, fileId)

	str = [];
	len = length(arr);
	if (len == 1 && ~isa(arr,'cell'))
		str = sprintf('%g',arr);
	else 
        str = convertFcnHandle(arr{1});
        for i = 2:len
            str = [str ' ' convertFcnHandle(arr{i})];
        end      
    end  
    
    function rstr = convertFcnHandle(val)
        if isa(val,'function_handle')
            rstr = func2str(val);
        else
            rstr = sprintf('%g',val);
        end    
    end
end
