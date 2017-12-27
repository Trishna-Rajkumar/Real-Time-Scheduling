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

function sched = testMaiaRTNS14(taskGSSG)
% performs the test by Maia et al. (RTNS 2014)

    global task;
    global m;
    
    sched = 1;
    
    for i = 1 : length(taskGSSG)
        
        maxPar(i) = max(taskGSSG(i).GSSGhl(:,2));
        
        taskGSSG(i).GSSG = computeAccWorkload(taskGSSG(i).GSSG);
        [~, q] = max([taskGSSG(i).GSSG.accWorkload]);
        cp = getCP(q, taskGSSG(i).GSSG);
        cpLength = taskGSSG(i).GSSG(q).accWorkload;
        taskGSSG(i).len = cpLength;
        
        Rold = cpLength;
        R = 0;
        init = 1;
        
        if Rold > task(i).D
            sched = 0;
            return;
        end
        
        while R ~= Rold && R <= task(i).D
            
            if init == 0
                Rold = R;
                R = 0;
            end
        
            for j = 1 : i - 1
                for k = 1 : maxPar(j)
                    R = R + getInterfFJ(j, k, Rold, taskGSSG);
                end
            end
            
            for j = 1 : maxPar(i)
                R = R + getSelfIntFJ(i, j, Rold, taskGSSG);
            end
            
            R = (1 / m) * R;
            R = floor(R);
            R = R + taskGSSG(i).len;
        
            init = 0;
        
        end 
        
        if R == Rold
            sched = 1;
            taskGSSG(i).R = R;
        elseif R > task(i).D    
            sched = 0;
            return;
        end
        
    end
end