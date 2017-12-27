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

function v = makeItDAG(v, prob)                                 
% starting from a conditional series-parallel graph, produces a DAG
% respecting the structural restricions imposed by conditional pairs

    % an edge can be added between i and j if
    for i = 1 : length(v)
        for j = 1 : length(v)
            if v(i).depth > v(j).depth && ...                   % the depth of the source is greater than that of the destination
               v(i).cond == 0 && ...                            % the source vertex is not conditional
               isequal(v(i).condPred, v(j).condPred) && ...     % they have the same conditional predecessors list
               isequal(v(i).branchList, v(j).branchList) && ... % they have the same list of branches taken
               ~ismember(j, v(i).succ) && ...                   % j is not already a successor of i     
               randi([1 100]) <= prob * 100                     % the probability of this event respects the given probability value
                    
                    v(i).succ = [v(i).succ j];
                    v(j).pred = [v(j).pred i];
            end
        end
    end
end