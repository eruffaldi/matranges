% logical to list of ranges start:end
function r = event2ranges(e)

if isempty(e)
    r = [];
else
q = diff(e);
change = find((abs(q) > 0)); % sorry no tilde in mac
if e(1) == 0
else
    change = [0,change(:)'];
end

if mod(length(change),2) == 1
    change = [change(:)',length(e)];
end
r = reshape(change,2,length(change)/2)';
r(:,1) = r(:,1)+1;
end