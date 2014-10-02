function r = rangefun(fun,ra,uniform)
% r = rangefun(fun,ra)
% executes fun(start,end) for every range in ra
%
% r = rangefun(fun,ra,uniform)
%
% When uniform (default) is true it expects a scalar values
if nargin < 3
    uniform = 1;
end

if uniform == 0
    r = cell(size(ra,1),1);
    for I=1:size(ra,1)
        r{I} = fun(ra(I,1),ra(I,2));
    end
else
    r = [];
    for I=1:size(ra,1)
        r = [r, fun(ra(I,1),ra(I,2))];
    end
end