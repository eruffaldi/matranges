% returns about ranges: length and separation to previous
function q = rangesinfo(r)

if isempty(r)
    q = [];
else
q = [r(:,2)-r(:,1)+1, [ 0 ; r(2:end,1)-r(1:end-1,2)-1]]; 
end
