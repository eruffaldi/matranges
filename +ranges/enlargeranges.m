function r = enlargeranges(r,side,n)

if isempty(r)
else
if nargin == 2
r = [max(1,r(:,1)-side),r(:,2)+side];
else
r = [max(1,r(:,1)-side),min(n,r(:,2)+side)];
    
end
end