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

function [v, mksp] = computeMakespanUB(v)
% returns an upper-bound to the makespan of the task graph composed of
% vertices in v 
    
    order = computeTopologicalOrder(v);
    
    v(order(end)).w = v(order(end)).C; 
    v(order(end)).w_set = order(end);
    v(order(end)).mksp = v(order(end)).C;
    v(order(end)).mksp_set = order(end);
    
    for z = length(order) - 1 : -1 : 1                                  % the nodes are examined in reverse topological order
        i = order(z);
        v(i).w = v(i).C;
        v(i).w_set = i;
        v(i).mksp = v(i).C;
        v(i).mksp_set = i;
        
        if ~isempty(v(i).succ)
            if v(i).cond == 0                                           % if the node is not a conditional head
                
                w = 0; wSet = [];
                [maxMksp, mkspSet] = maximizeMakespan(i, v);
                
                v(i).mksp = maxMksp + v(i).C;
                v(i).mksp_set = [i mkspSet];

                for j = 1 : length(v(i).succ)
                    newVert = setdiff(v(v(i).succ(j)).w_set, wSet);
                    wSet = [wSet newVert];

                    for k = 1 : length(newVert)
                        w = w + v(newVert(k)).C;
                    end    
                end

                v(i).w = v(i).w + w;
                v(i).w_set = [v(i).w_set wSet];
                   
            else                                                        % if the node is a conditional head  
                maxMksp = 0;
                
                for j = 1 : length(v(i).succ)
                    
                    if v(v(i).succ(j)).mksp > maxMksp
                        maxMksp = v(v(i).succ(j)).mksp;
                        indM = j;
                    end
                    
                end
                
                v(i).mksp = v(i).mksp + maxMksp;
                v(i).mksp_set = [v(i).mksp_set v(v(i).succ(indM)).mksp_set];
                               
                maxW = 0;
                
                for j = 1 : length(v(i).succ)
                    
                    if v(v(i).succ(j)).w > maxW
                        maxW = v(v(i).succ(j)).w;
                        indW = j;
                    end
                    
                end
                
                v(i).w = v(i).w + v(v(i).succ(j)).w;
                v(i).w_set = [v(i).w_set v(v(i).succ(indW)).w_set];
            end
        end
        
    end
    
    mksp = v(order(1)).mksp;
   
end