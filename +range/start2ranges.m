% logical to list of ranges start:end
function r = start2ranges(e,n)

if isempty(e)
    r = [];
else

    if nargin < 2
        n = max(e);
    end
q = e;

r = [q; q(2:end)-1, n]';
end