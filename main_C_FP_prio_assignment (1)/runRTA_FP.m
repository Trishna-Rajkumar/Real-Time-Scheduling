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

function [R, sched] = runRTA_FP(ind, makespan)
% response-time analysis in the case of FP

    global task;
    global m;
    
    Rold = makespan;                % initial value for R is the upper-bound on the makespan of task ind
    R = 0;
    init = 1;
    
    if Rold > task(ind).D
       sched = 0;
       return;
    end
    
    while R ~= Rold && R <= task(ind).D
        if init == 0
            Rold = R;
            R = 0;
        end
        
        if ind > 1
            for i = 1 : ind - 1
                R = R + (1 / m) * getInterf(i, Rold);
            end

            R = floor(R);
            R = R + makespan;
           
        else
            R = Rold;
        end
        
        init = 0;
        
    end 
    
    if R == Rold
        sched = 1;
        return;
    elseif R > task(ind).D    
        sched = 0;
        return;
    end
    
end