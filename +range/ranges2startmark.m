function r = ranges2start(ra,n)

if nargin < 2
	n = max(ra);
end
r = zeros(n,1);
r(ra(:,1)) = 1:size(ra,1);
