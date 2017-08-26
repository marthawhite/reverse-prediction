function opts = getOptions(opts, DEFAULTS) 

    if isempty(DEFAULTS)
        return
    elseif isempty(opts)
	    opts = DEFAULTS;
	else
		fields = fieldnames(DEFAULTS);
		for i=1:length(fields),
		    f = fields{i};
		    if (~isfield(opts,f)),
		        opts = setfield(opts,f,getfield(DEFAULTS,f));
		    end
		end
	end

end
