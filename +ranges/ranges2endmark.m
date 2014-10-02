function r = ranges2endmark(ra,n)

if nargin < 2
	n = max(ra);
end
r = zeros(n,1);
r(ra(:,2)) = 1:size(ra,1);
