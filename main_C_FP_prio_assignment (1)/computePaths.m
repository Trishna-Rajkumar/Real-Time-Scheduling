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

function paths = computePaths(v)
% computes the different paths in a conditional DAG (used for the test by Fonseca et al.)

    order = computeTopologicalOrder(v);
    paths(1).list = 1;
    paths.succ = nan(length(v));    % matrix of successors
    paths.pred = nan(length(v));    % matrix of predecessors
    
    for z = 1 : length(order)                                                         
        i = order(z);
        if v(i).cond == 0   
            for j = 1 : length(v(i).succ)
                for k = 1 : length(paths)
                    if ismember(i, paths(k).list) 
                        if ~ismember(v(i).succ(j), paths(k).list)
                            paths(k).list = [paths(k).list v(i).succ(j)];
                        end
                        paths(k).succ(i,v(i).succ(j)) = v(i).succ(j);
                        paths(k).pred(v(i).succ(j), i) = i;
                    end
                end
            end
        else                                
            for k = 1 : length(paths)
                if ismember(i, paths(k).list)
                    if ~isempty(v(i).succ)
                        for j = 1 : length(v(i).succ)
                            if j == 1
                                paths(k).list = [paths(k).list v(i).succ(1)];
                                paths(k).succ(i,v(i).succ(1)) = v(i).succ(1);
                                paths(k).pred(v(i).succ(1), i) = i;
                            else
                                paths(end + 1) = paths(k);
                                paths(end).list(end) = v(i).succ(j);
                                paths(end).succ(i,v(i).succ(1)) = NaN;
                                paths(end).succ(i,v(i).succ(j)) = v(i).succ(j);
                                paths(end).pred(v(i).succ(1), i) = NaN;
                                paths(end).pred(v(i).succ(j), i) = i;
                            end
                        end  
                    end
                end
            end
        end
    end
end

