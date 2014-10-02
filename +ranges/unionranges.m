function r = unionranges(a,b)

if isempty(a)
    r = b;
elseif isempty(b)
    r = a;
else
n = max(max(b(:,2)),max(a(:,2)));
r = event2ranges(ranges2event(a,n) | ranges2event(b,n));
end