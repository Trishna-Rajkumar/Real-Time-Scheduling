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

function sched = runRTA_EDF()
% response-time analysis in the case of EDF

    global task;
    global m;
    
    Rold = zeros(1, length(task));                
    
    for i = 1 : length(Rold)
        Rold(1, i) = task(i).mksp;
        task(i).R = task(i).mksp;
    end
    
    R = zeros(1, length(task));
    
    init = 1;
    changed = 1;
    sched = 1;
   
    while changed == 1    
        changed = 0;
        
        for i = 1 : length(task)

            if Rold(1,i) > task(i).D
               sched = 0;
               return;
            end

            if init == 0
                Rold(1,i) = R(1,i);
                R(1,i) = 0;
            end

            if length(task) > 1
                for j = 1 : length(task)
                    if j ~= i
                        R(1,i) = R(1,i) + (1 / m) * getInterf_EDF(j, Rold(1,i), i);    
                    end
                end
                
                R(1,i) = R(1,i) + task(i).mksp;
                R(1,i) = floor(R(1,i));

            else
                R(1,i) = Rold(1,i);
            end

            task(i).R = R(1,i);
            
            if R(1,i) ~= Rold(1,i)
                changed = 1;
            end    
                
            if R(1,i) > task(i).D
                sched = 0;
                return;
            end
        end
        init = 0;
        
    end
  
    sched = 1;
    
    for i = 1 : length(task)
        task(i).R = R(1,i);
    end  
end