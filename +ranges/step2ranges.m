% logical to list of ranges start:end
function r = step2ranges(x,k)

if isempty(e)
    r = [];
else

a = [1];
q = k;
for I=1:length(x)
	if x(I) >= q
		q = q + k;
		a = [a, I];
	end
if a(end) < length(x)
	a = [a,I];
end
