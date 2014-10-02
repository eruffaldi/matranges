% ranges 2 logical optionally with maximum length when r is not ending at
% end
function e = ranges2logic(r,n)

if nargin == 1
    n = max(r(:,2));
end
e = zeros(n,1);
for I=1:size(r,1)
    e(r(I,1):r(I,2)) = 1;
end
