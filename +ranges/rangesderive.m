function [V,A] = rangesderive(d,er)

% apply by ranges
if isempty(er)
    V = velestuni(d,1);
    A = accestuni(d,1);
else            
    V = zeros(size(d));
    A = zeros(size(d));
    for J=er'
        D = d(J(1):J(2),:);
        V(J(1):J(2),:) = velestuni(D,1);
        A(J(1):J(2),:) = accestuni(D,1);
    end
end  