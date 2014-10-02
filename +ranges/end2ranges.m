function r = end2ranges(e)
% logical to list of ranges start:end
%
% NOTE: repetitions not supported

if isempty(e)
    r = [];
else

q = e;

r = [1,q(1:end-1)+1; q]';
end