function r = ranges2endmark(ra,n)

if nargin < 2
	n = max(ra);
end
if size(ra,2) == 3
    m = ra(:,3);
else
    m = 1:size(ra,1);
end

r = zeros(n,1);
for I=1:size(ra,1)
    r(ra(I,1):ra(I,2)) = m(I);
end
