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

function w = workTask(ind, t, sigma)
% computes the work function of a task (used for the test by Baruah)

    global task;
    
    % task_inc is the inflated task (based on the value of sigma)
    
    task_inc = task(ind);
    
    for i = 1 : length(task_inc.v)
        task_inc.v(i).C = task_inc.v(i).C / sigma;
    end
    
    task_inc.vol = computeVolume(task_inc.v);
    task_inc.v = computeAccWorkload(task_inc.v);
    [~, q] = max([task_inc.v.accWorkload]);
    task_inc.len = task_inc.v(q).accWorkload;
    
    % here we compute the work function at time t
    
    nfull = 0;
    npart = 0;
    
    work_part = 0;
    
    if t >= task(ind).D
        nfull = floor((t - task(ind).D) / task(ind).T) + 1;
        npart = ceil(t / task(ind).T) - nfull;
    end
    
    work_full = nfull * task_inc.vol;
    
    curr_d = t - (nfull - 1) * task(ind).T;
    curr_r = t - (task(ind).D + (nfull - 1) * task(ind).T);
    
    for i = 1 : npart
        curr_d = curr_d - task(ind).T;
        curr_r = curr_d - task(ind).D;
        
        for j = 1 : length(task_inc.v)
            vert_r = curr_r + localOffset(task_inc, j);
            
            if vert_r >= 0
                work_part = work_part + task_inc.v(j).C;
            elseif vert_r + task_inc.v(j).C > 0
                work_part = work_part + task_inc.v(j).C + vert_r;
            end
        end
    end
    
    w = work_full + work_part;
end