matranges
=========

Small MATLAB toolbox for manipulating data ranges. This allows to extract ranges from labels, logical or raising levels and perform operations

Two implementations are provided: one as package, one as class

========


Range Operations for MATLAB
by Emanuele Ruffaldi 2010-2011
------------------------------

Range data is common in many operations, it is a trivial task but this code tries to make some order...

Which are the representation or sources of ranges?

- [start,end] sequence of indices, eventually enforcing to be not overlapping and/or monotonic in start. 
	- in the case ranges are not overlapping, consecutive and monotonic only start is necessary
- logical marker of start or end, for consecutive ranges like 0 1 0 0 0 0 1 0 0 0 1 
- event logical: 1 1 1 1 1 0 0 0 0 1 1 1 1 1
- marker of group 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3

The (start,end) sequence is the most efficient for subset selection, but for reconstructing the other two it requires the full length of the original data

Also end can be inside [a,b] or outside the range [a,b). Just a matter of convention. The event logical format is very useful for performing combination of separate range sets.

If 

Operations:

- conversion among formats, the natural one is [start,end]
	end2ranges
	start2ranges
	event2ranges
	ranges2event	
- enlarge range by given amount
	enlargeranages(ra,amount)
- merge ranges that are distant less than given value
	mergeranges(ra,threshold)
- velocity estimator based on range margin
	[V,A] = rangesderive(data,range)
		It computes velocity and estimation using ranges as boundaries for vel/acc estimator
- merge of two range sets
	mergeranges(ra1,ra2)
- apply function
	rangefun(fun,ra1)
		applies range to function calling fun(start,end) 

