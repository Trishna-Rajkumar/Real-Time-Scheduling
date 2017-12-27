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

function [v, wSet, wValue] = computeWorstCaseWorkload(v)
% returns the worst-case workload of the conditional DAG represented by v

    order = computeTopologicalOrder(v);
    
    v(order(end)).path = order(end);
    
    for z = length(order) - 1 : -1 : 1                                      % the nodes are examined only once
        i = order(z);
        v(i).path = i;
        
        if ~isempty(v(i).succ)
            if v(i).cond == 0                                               % if successors are not conditional, we add all of them to the current node path
                for j = 1 : length(v(i).succ)
                    v(i).path = union(v(i).path, v(v(i).succ(j)).path);    
                end
            else                                                            % otherwise we take the maximum sumW and add only this to the current node path
                C = zeros(1,length(v(i).succ));
                for j = 1 : length(v(i).succ)
                    for k = 1 : length(v(v(i).succ(j)).path)
                       C(j) = C(j) + v(v(v(i).succ(j)).path(k)).C;
                    end
                end
                
                [~, index] = max(C);
                v(i).path = union(v(i).path, v(v(i).succ(index)).path);
            end
        end
        
    end
    
    wSet = v(order(1)).path;
    
    wValue = 0;
    
    for i = 1 : length(wSet)
        wValue = wValue + v(wSet(i)).C;
    end
end