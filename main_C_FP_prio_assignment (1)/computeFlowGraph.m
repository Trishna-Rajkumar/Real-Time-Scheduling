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

function v = computeFlowGraph(ind, path)
% used in the test by Fonseca et al.

    global task;
    
    v = struct('C', {}, 'id', {}, 'pred', {}, 'succ', {});
    
    for i = 1 : length(path.list)
        curr = path.list(i);
        v(i).C = task(ind).v(curr).C; 
        v(i).id = curr;
        v(i).succ = path.succ(curr,:);
        v(i).succ(find(isnan(v(i).succ))) = [];
        
        v(i).pred = path.pred(curr, :);
        v(i).pred(find(isnan(v(i).pred))) = [];
    end
    
    idList = [v(:).id];
    
    for i = 1 : length(path.list)    
        for j = 1 : length(v(i).succ)
             newEl = find(idList == v(i).succ(j));
             if ~isempty(newEl)
                v(i).succ(j) = newEl;
             end
        end
        
        for j = 1 : length(v(i).pred)
            newEl = find(idList == v(i).pred(j));
            if ~isempty(newEl)
                v(i).pred(j) = newEl;
            end
        end
    end
    
end