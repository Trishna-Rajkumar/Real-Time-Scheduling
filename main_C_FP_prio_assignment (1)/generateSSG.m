% 
% cptasks - A MATLAB(R) implementation of schedulability tests for
% conditional and parallel tasks
%
% Copyright (C) 2014-2015  
% ReTiS Lab - Scuola Superiore Sant'Anna - Pisa (Italy)
%
% cptasks is free software; you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% version 2 as published by the Free Software Foundation, 
% (with a special exception described below).
%
% Linking this code statically or dynamically with other modules is
% making a combined work based on this code.  Thus, the terms and
% conditions of the GNU General Public License cover the whole
% combination.
%
% cptasks is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License version 2 for more details.
%
% You should have received a copy of the GNU General Public License
% version 2 along with cptasks; if not, write to the
% Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301 USA.
%
%
% Author: 2015 Alessandra Melani
%

function [SSG, SSGhl] = generateSSG(v)
% used to perform the transformation by Fonseca et al.

    cutNodes = [];                                                  % vertices that have been eliminated
    SSG = struct('C', {}, 'pred', {}, 'succ', {});
    newNumber = 0;                                                  % number of vertices currently added to cutNodes
    currSSGLen = 0;                                                 % current number of vertices of the SSG
    order = computeTopologicalOrder(v);
    SSGhl = [];                                                     % high-level structure of the SSG (i.e., <WCET, #vert>)
    
    while length(cutNodes) ~= length(order)
        SCurr = [];
        for z = 1 : length(order)
            i = order(z);
            if ~ismember(i, cutNodes) && isempty(setdiff(v(i).pred, cutNodes)) 
                SCurr = [SCurr i];                                  % SCurr contains the vertices without predecessors
            end
        end
        
        CMin = min([v(SCurr).C]);                                   % and their minimum WCET
        
        SSGhl = [SSGhl; [CMin, length(SCurr)]];
        
        for i = 1 : length(SCurr)
            newV.C = CMin;                                          % a new vertex is created for each element belonging to SCurr
            newV.pred = currSSGLen - newNumber + 1 : currSSGLen;    % set as predecessors the nodes of the previous segment
            newV.succ = [];
            
            for j = currSSGLen - newNumber + 1 : currSSGLen
                SSG(j).succ = [SSG(j).succ (length(SSG) + 1)];      % set new node as successor of the previous segment
            end
            
            SSG(end + 1) = newV;                                    % add new vertex to the SSG
            
            v(SCurr(i)).C = v(SCurr(i)).C - CMin;                   % decrease its WCET by CMin time units
            
            if v(SCurr(i)).C == 0
                cutNodes = [cutNodes SCurr(i)];                     % if its WCET has become zero, add it to cutNodes
            end
            
        end
        newNumber = length(SCurr);
        currSSGLen = length(SSG);
    end
end