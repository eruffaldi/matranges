% given:
% - X
% - acceleration
% - 
function Y = rangesint(X,er,acc,h)

if nargin < 4
    h = 1;
end
% apply by ranges
if isempty(er)
    Y = intestuni(X(1,:),X(2,:),acc,h);
else            
    Y = X;
    for J=er'
        if J(2)-J(1) > 2
            D = X(J(1):J(2),:);
            w = intestuni(D(1,:),D(2,:),acc(J(1):J(2),:),h);
            Y(J(1):J(2),:) = w;
        end
    end
end  