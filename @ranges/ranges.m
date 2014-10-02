% Ranges Class
% ranges manipulation class in matlab
%
% Internal representation: list of (start,inclusive end,label)
%
% External representations for input/output:
% - list of labels
% - list of changes (new range when value changes)
% - logical
%
% Emanuele Ruffaldi 2011-2014
classdef ranges
    
    properties
        values
        n
        islabeled
    end
   
    methods
        % constructor 
        %
        % ranges(values)
        % ranges(values,n)
        % ranges(values,islabeled)
        %
        % values is a matrix with ranges along rows and with columns as
        % (start,stop,[label])
        function r = ranges(values,n,islabeled)
            if nargin < 2
                n = max(values(:,2));
            end
            if nargin < 3
                islabeled = size(values,2) == 3;                
            end
            r.values = values;
            r.n = n;
            r.islabeled = islabeled;
        end
        
        % returns the ranges
        function r = double(this)
            r = this.values;
        end
        
        % converts to logical
        function e = logical(this)
            r = this.values;
            e = zeros(this.n,1);
            for I=1:size(r,1)
                e(r(I,1):r(I,2)) = 1;
            end
        end
        
        % returns number of ranges
        function n = length(this)
            n = size(this.values,1);
        end
        
        % returns extent, that is used for back conversion
        function n = extent(this)
            n = this.n;
        end
        
        function this = setextent(this,n)
            this.n = n;
        end
        
        % returns list of labels
        function l = labels(this)
            if size(this.values,2) == 3
                l = unique(this.values(:,3));
            else
                l = [];
            end
        end    
        
        % converts to labeled, or eventually indexed if labels are missing
        function e = aslabels(this)
             r = this.values;
             e = zeros(this.n,1);

            if size(r,2) == 3
                for I=1:size(r,1)
                    e(r(I,1):r(I,2)) = r(I,3);
                end
            else

                for I=1:size(r,1)
                    e(r(I,1):r(I,2)) = I;
                end
            end
        end       
        
        % merges two ranges, assuming they are logical        
        function r = union(this,other)
            assert(this.islabeled == 0,'union only for not labeled');
            a = this.values;
            b = other.values;
            n = max(max(b(:,2)),max(a(:,2))); % enlarge
            this.n = n;
            other.n = n;
            r = ranges.fromlogical(aslogical(this) | aslogical(other));        
        end
        
        % returns the lengths of the ranges
        function l = lengths(this)
            r = this.values;
            l = [r(:,2)-r(:,1)+1];
        end
        
        % returns the separation
        function s = separations(this)
            r = this.values;
            s = [ 0 ; r(2:end,1)-r(1:end-1,2)-1]; 
        end
        
        % function enlarges the ranges by amount
        function this = enlargeranges(this,side)        
            if isempty(this.values)                
            else
                this.values = [max(1,r(:,1)-side),min(n,r(:,2)+side),r(:,3)];
            end
        end

        % merge ranges that are separated less than th
        function r = merge(this,th)
            rin = this.values;
            
            neg = [rin(1:end-1,2)+1,rin(2:end,1)-1]; % negative part of the ranges
            l = (neg(:,2)-neg(:,1)+1);
            neg = neg(l <= th & l > 0,:); % not empty and longer equal then th

            if isempty(neg)
                r = this;
            else
                % not a special algorithm just join the ranges and convert back and
                % front
                %r = event2ranges(ranges2event([rin;neg]));
                r  = [rin;neg];
                n = max(r(:,2));
                e = zeros(n,1);
                for I=1:size(r,1)
                    e(r(I,1):r(I,2)) = 1;
                end
                r = ranges.fromlogical(e);
            end
        end
        
        % returns the target space with the marker of starts
        function r = starts(this)
            n = this.n;
            ra = this.values;
            r = zeros(n,1);
            r(ra(:,1)) = 1:size(ra,1);
        end
        
        % returns the target space with the marker of ends
        function r = ends(this)
            n = this.n;
            ra = this.values;
            r = zeros(n,1);
            r(ra(:,2)) = 1:size(ra,2);
        end
        
        % applyes a function to all the ranges passing the start and end
        % indices
        function r = apply(this,fun,isuniform)
            if nargin == 2
                isuniform = 1;
            end
            ra = this.values;
            
            if isuniform == 0
                r = cell(size(ra,1),1);
                for I=1:size(ra,1)
                    r{I} = fun(ra(I,1),ra(I,2));
                end
            else
                r = [];
                for I=1:size(ra,1)
                    r = [r, fun(ra(I,1),ra(I,2))];
                end
            end            
        end
        
        % TODO: rangesintegral
        % TODO: rangesderivation provided functions for acc and vel
        % TODO: ranges2endmark
    end
    
    methods (Static)
        % NOT done: fromsteps : step2ranges
        % NOT done: fromstart, fromend
        
        % returns ranges from the events
        function ret = fromlogical(e)
            ret = ranges.fromevents(e);
        end
        
        % returns ranges from any variation
        function ret = fromevents(e)
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
            ret = ranges(r,length(e),0);
        end
        
        % returns ranges from the labels
        function ret = fromlabels(d)
            if size(d,1) > 1
                d = d';
            end

            a = diff(d);
            a(end) = 1;
            af = find(a);

            r = [1,af(1:end-1)+1; af]';
            r(:,3) = d(af);
            ret = ranges(r,length(d),1);
        end
    end
    
end
