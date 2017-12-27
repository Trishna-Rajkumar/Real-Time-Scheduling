% The MIT License (MIT)
% 
% Copyright (c) 2015 Kelly Kearney
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy of
% this software and associated documentation files (the "Software"), to deal in
% the Software without restriction, including without limitation the rights to
% use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
% the Software, and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
% FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
% COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
% IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
% CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function pth = pathbetweennodes(adj, src, snk, verbose)
%PATHBETWEENNODES Return all paths between two nodes of a graph
%
% pth = pathbetweennodes(adj, src, snk)
% pth = pathbetweennodes(adj, src, snk, vflag)
%
%
% This function returns all simple paths (i.e. no cycles) between two nodes
% in a graph.  Not sure this is the most efficient algorithm, but it seems
% to work quickly for small graphs, and isn't too terrible for graphs with
% ~50 nodes.
%
% Input variables:
%
%   adj:    adjacency matrix
%
%   src:    index of starting node
%
%   snk:    index of target node
%
%   vflag:  logical scalar for verbose mode.  If true, prints paths to
%           screen as it traverses them (can be useful for larger,
%           time-consuming graphs). [false]
%
% Output variables:
%
%   pth:    cell array, with each cell holding the indices of a unique path
%           of nodes from src to snk.

% Copyright 2014 Kelly Kearney

if nargin < 4
    verbose = false;
end

n = size(adj,1);

stack = src;

stop = false;

pth = cell(0);
cycles = cell(0);

next = cell(n,1);
for in = 1:n
    next{in} = find(adj(in,:));
end

visited = cell(0);

pred = src;
while 1
    
    visited = [visited; sprintf('%d,', stack)];
    
    [stack, pred] = addnode(stack, next, visited, pred);
    if verbose
        fprintf('%2d ', stack);
        fprintf('\n');
    end
    
    if isempty(stack)
        break;
    end
    
    if stack(end) == snk
        pth = [pth; {stack}];
        visited = [visited; sprintf('%d,', stack)];
        stack = popnode(stack);
    elseif length(unique(stack)) < length(stack)
        cycles = [cycles; {stack}];
        visited = [visited; sprintf('%d,', stack)];
        stack = popnode(stack);  
    end

end


function [stack, pred] = addnode(stack, next, visited, pred)

newnode = setdiff(next{stack(end)}, pred);
possible = arrayfun(@(x) sprintf('%d,', [stack x]), newnode, 'uni', 0);

isnew = ~ismember(possible, visited);

if any(isnew)
    idx = find(isnew, 1);
    stack = str2num(possible{idx});
    pred = stack(end-1);
else
    [stack, pred] = popnode(stack);
end


function [stack, pred] = popnode(stack)

stack = stack(1:end-1);
if length(stack) > 1
    pred = stack(end-1);
else
    pred = [];
end