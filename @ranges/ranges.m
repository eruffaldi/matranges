% Ranges Class
% ranges manipulation class in Matlab
%
% Internal representation: list of (start,inclusive end,label) plus
% original length used for rebuilding back and forth
%
% External representations for input/output:
% - array of labels
% - array of changing points
% - logical
%
% Emanuele Ruffaldi 2011-2018
classdef ranges
    
    properties
        values
        n
    end
    
    properties (Dependent = true)
        islabeled
        extent
    end
   
    methods
        % constructor 
        %
        % ranges(L,[n])
        % ranges(A,[n])
        % ranges(R,[n])
        %
        % L is logical
        % A is labels
        % R is ranges values (start,end,label) or (start,end)
        %
        % Length n is used for reconstruction
        function r = ranges(X,n)
            if islogical(X)
                if nargin == 1
                    n = size(X,1);
                end
                r = ranges.fromlogical(X,n);
            elseif size(X,2) == 2
                r.values = X;
                if nargin == 1
                    n = max(X(:,2));
                end
                r.n = n;
            elseif size(X,2) == 3
                r.values = X;
                if nargin == 1
                    n = max(X(:,2));
                end
                r.n = n;
            else
                error('bad input');
            end
        end
        
        % returns the ranges
        function r = double(this)
            r = this.values;
        end
        
        % labeled
        function value = get.islabeled(this)
            value = size(this.values,2) == 3;
        end
        
        % preserve the ranges whose length is in range [minlength,maxlength]
        function r = filterlength(this,minlength,maxlength)
            L = this.lengths();
            r = this;
            r.values = r.values(L >= minlength & L <= maxlength,:);
        end

        % filter all ranges inclusively inside [minstart,maxend)
        % ASSUMES sorted
        function this = filterbeginend(this,minstart,maxend)
            fi = find(this.values(:,1)>=minstart,1,'first');
            fe = find(this.values(:,2)<=maxend,1,'last');
            this.values = this.values(fi:fe,:);
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
        function n = get.extent(this)
            n = this.n;
        end
        
        % changes extent
        function this = set.extent(this,n)
            this.n = n;
        end

        % returns the lengths of the ranges
        function l = lengths(this)
            r = this.values;
            l = r(:,2)-r(:,1);
        end

        % returns list of labels, otherwise if not labeled done empty
        function l = labels(this)
            if size(this.values,2) == 3
                l = unique(this.values(:,3));
            else
                l = [];
            end
        end    
        
        % merges two range sets
        function r = union(this,other)
            assert(this.islabeled == 0,'union only for not labeled');
            a = this.values;
            b = other.values;
            n = max(max(b(:,2)),max(a(:,2))); % enlarge
            this.n = n;
            other.n = n;
            r = ranges.fromlogical(aslogical(this) | aslogical(other),this.n);        
        end
        
        % returns the separation between intervals
        function s = separations(this)
            r = this.values;
            s = [ 0 ; r(2:end,1)-r(1:end-1,2)-1]; 
        end
        
        % function enlarges the ranges by amount
        function this = enlargeranges(this,side)        
            if length(side) == 1
                side = [side,side];
            end
            if isempty(this.values)                
            else
                n = this.n;
                r = this.values;
                if size(r,2) == 2
                    r = [max(1,r(:,1)-side(1)),min(n,r(:,2)+side(2))];
                else
                    r = [max(1,r(:,1)-side(1)),min(n,r(:,2)+side(2)),r(:,3)];
                end
                this.values = r;
            end
        end

        % merge ranges that are separated less than given threshold. 
        %
        % IF labeled uses the label of FIRST?
        function r = merge(this,th)
            rin = this.values;
            
            if size(rin,2) == 3
                neg = [rin(1:end-1,2),rin(2:end,1),rin(1:end-1,3)]; % negative using label from first
            else
                neg = [rin(1:end-1,2),rin(2:end,1)]; % negative part of the ranges
            end
            l = neg(:,2)-neg(:,1); % length of the intervals
            neg = neg(l <= th & l > 0,:); % not empty and longer equal then th

            if isempty(neg)
                r = this;
            else
                r  = [rin;neg];
                if size(r,2) == 3
                    e = zeros(this.n,1);
                    for I=1:size(r,1)
                        e(r(I,1):r(I,2)) = r(I,3);
                    end
                    r = ranges.fromlabels(e,this.n);
                else
                    e = zeros(this.n,1);
                    for I=1:size(r,1)
                        e(r(I,1):r(I,2)) = 1;
                    end
                    r = ranges.fromlogical(e,this.n);
                end
            end
        end
    
        % return TRUE if the ranges cover all the span [1..n]
        function b = isfull(this)
            if isempty(this.values)
                b = true;
            else
                b = sum(this.lengths()) == this.n;
            end
        end
        
        % returns FULL array of RANGE INDEX
        function X = torangeindex(this)    
            X = makerangeindexed.torangelabel();
        end

        % returns FULL array of INRANGE
        function X = torangemask(this)
            X = this.makerangemask().torangelabel();
        end
        
        % returns FULL array of LABELS with 0 as default
        function X = torangelabel(this)
            if this.islabeled == 0
                this = this.makerangeindexed();
            end
            ra = this.values;
            X = zeros(this.n,1);
            for I=1:size(ra,1)
                X(ra(I,1):ra(I,2)) = ra(I,3);
            end
        end              
        

        % sets LABEL as the index of the RANGE
        function this = makerangeindexed(this)    
            this.values(:,3) = 1:size(this.values,1);
        end
        
        % sets LABEL as the presence of the RANGE
        function this = makerangemask(this)    
            this.values(:,3) = true(size(this.values,1),1);
        end
        
        % returns the target space with the marker of starts
        function r = starts(this)
            n = this.n;
            ra = this.values;
            r = zeros(n,1);
            r(ra(:,1)) = 1:size(ra,1);
        end
        
        % returns the target space with the marker of ends
        function X = ends(this)
            ra = this.values;
            X = zeros(this.n,1);
            X(ra(:,2)) = 1:size(ra,2);
        end
        
        % applyes a function to all the ranges passing the start and end
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
                
        % joints data with nan, e.g. for plot or line
        function [I,J,outsize] = compactwithnan_build(this)            
            S = this.values;
            L = sum(this.lengths());
            outsize = size(S,1)-1+L;
            I = zeros(L,1);
            J = zeros(L,1);
            t = 1;
            j = 1;
            for k=1:size(S,1)
                q = S(k,2)-S(k,1);
                I(j:j+q) = t:t+q; % dest
                J(j:j+q) = S(k,1):S(k,2); % input
                j = j + q + 1; % next j is at j+q+1
                t = t + q + 2; % next starts at t+q+2 due to nan 
            end
        end
        
        % q = [1:9;2*(1:9)]'
        % r = ranges.fromlabels([1,2,3,3,3,4,4,4,5]);
        % Y = r.compactwithnan(q)
        %
        % Y has length 11 with splitted nan
        %
        % r = r.filterlength(3,10)
        % Y2 = r.compactwithnan(q) % returns 7 rows
        % Y3 = r.compact(q);  % returns 6 rows selected
        %
        
        function Y = compactwithnan(this,X,I,outsize)
            if nargin == 2
                [I,J,outsize] = compactwithnan_build(this);
            end

            s = size(X);
            s(1) = outsize;
            Y = nan(s);
            if ~isempty(J)
                if ndims(X) < 3
                    Y(I,:) = X(J,:);
                else
                    Y(I,:,:) = X(J,:,:);
                end
            else
                if ndims(X) < 3
                    Y(I,:) = X;
                else
                    Y(I,:,:) = X;
                end
            end
        end

        % joints data with nan, e.g. for plot or line
        function [I,J,outsize] = compact_build(this)            
            S = this.values;
            L = sum(this.lengths());
            outsize = size(S,1)-1+L;
            J = zeros(L,1);
            j = 1;
            for k=1:size(S,1)
                q = S(k,2)-S(k,1);
                J(j:j+q) = S(k,1):S(k,2); % input
                j = j + q + 1; % next j is at j+q+1
            end            
            I = [];
        end
        
        function Y = compact(this,X,J)
            if nargin < 3
                [~,J,~] = compact_build(this);
            end
            if ~isempty(J)
                if ndims(X) < 3
                    % this applies also for table
                    Y = X(J,:);
                else
                    Y = X(J,:,:);
                end
            else
                if ndims(X) < 3
                    Y = X;
                else
                    Y = X;
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
        function ret = fromlogical(e,n)
            if nargin == 1
                n = length(e);
            end
            ret = ranges.fromevents(e,n);
        end
        
        % returns ranges from any variation
        function ret = fromevents(e,n)
            if nargin == 1 || isnan(n)
                n = length(e);
            end
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
            ret = ranges(r,n);
        end
        
        function ret = fromstart(s,n)
            if nargin == 1
                n = length(s);
            end
            r = zeros(length(s),3);
            r(:,1) = s;
            r(:,2) = [s(2:end);n];
            r(:,3) = 1:length(s);
            ret = ranges(r,n);
        end

        % returns ranges from the labels
        function ret = fromlabels(d,n)
            if nargin < 2
                n = length(d);
            end
            if size(d,1) > 1
                d = d';
            end

            a = diff(d);
            a(end) = 1;
            af = find(a);

            r = [1,af(1:end-1)+1; af]';
            r(:,3) = d(af);
            r = r(r(:,3) > 0,:); % exclude 0
            ret = ranges(r,n);
        end
    end
    

end

