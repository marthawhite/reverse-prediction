function [varargout] = funcomb2(fun1,fun2,varargin)
% componentwise addition of output lists from two functions

n = nargout;
o1 = cell(1,n);
o2 = cell(1,n);
[o1{:}] = fun1(varargin{:});
[o2{:}] = fun2(varargin{:});

for i = 1:n
	varargout{i} = o1{i} + o2{i};
end
