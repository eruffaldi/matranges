clear all
clear classes
% given labels

ex = [1 1 1 2 3 3 4 4 5 5 5 6 7];
r2 = ranges.fromlabels(ex);
length(r2)
%r3 = ranges.merge(2);
separations(r2)
double(r2)


a = sin(0:0.1:3*pi)';
r2 = ranges.fromlogical(a > 0);
double(r2)
plot([a,r2.starts(),r2.ends()])
