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

function [maxMksp, mkspSet] = maximizeMakespan(i, v)
% refined upper-bound on makespan in the case of non-conditional vertex

    global m;
    
    maxMksp = 0;
    
    for j = 1 : length(v(i).succ)
        
        sumW = 0;
        wSet = [];
        
        for k = 1 : length(v(i).succ)
            if k ~= j  
                newVert = setdiff(v(v(i).succ(k)).w_set, wSet);
                newVert = setdiff(newVert, v(v(i).succ(j)).mksp_set);
                wSet = [wSet newVert];

                for w = 1 : length(newVert)
                    sumW = sumW + v(newVert(w)).C;
                end    
            end
        end    
        
        if (v(v(i).succ(j)).mksp + (sumW / m)) > maxMksp    
            maxMksp = v(v(i).succ(j)).mksp + (sumW / m);
            mkspSet = [v(v(i).succ(j)).mksp_set, wSet];
        end
    end
end