% ranges 2 logical optionally with maximum length when r is not ending at
% end
function e = ranges2events(r,n)

if nargin == 1
    n = max(r(:,2));
end
e = zeros(n,1);

if size(r,2) == 3
for I=1:size(r,1)
    e(r(I,1):r(I,2)) = r(I,3);
end
else
    
for I=1:size(r,1)
    e(r(I,1):r(I,2)) = I;
end
end
