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

close all;
clear all;

global m;
global task;
global maxCondBranches;
global maxParBranches;
global p_cond;
global p_par;
global p_term;

workspace_name = 'FP_U.mat';
maxCondBranches = 2; 
maxParBranches = 6;
p_cond = 0;
p_par = 0.8;
p_term = 0.2;
rec_depth = 2;
Cmin = 1;
Cmax = 100;
beta = 0.1;

tasksetsPerU = 1;
addProb = 0.1;
m = 8;
lost = 0;
Umin = 0;
Umax = 8;
U = 0;
Ucurr = Umin;
stepU = 0.25;
save_rate = 25;
print = 0;

nTasksets = tasksetsPerU * ((Umax - Umin) / stepU);
vectorU_RTAFP = zeros(1, (Umax - Umin) / stepU);
vectorU_Maia = zeros(1, (Umax - Umin) / stepU);
task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

for x = 1 : nTasksets

    if rem(x - 1, tasksetsPerU) == 0
        Ucurr = Ucurr + stepU;
    end
    
    U = 0;
   
    schedRTAFP = 0;
    schedMaia = 0;
    
    i = 0;
    
    % generation of the DAG-tasks
    while 1
        
        i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});

        task(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = makeItDAG(task(i).v, addProb);

        if print == 1
            printTask(task(i).v);
        end

        task(i).v = computeAccWorkload(task(i).v);
        [~, q] = max([task(i).v.accWorkload]);
        cp = getCP(q, task(i).v);
        task(i).len = task(i).v(q).accWorkload;

        [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);

        task(i) = generateSchedParameters(i, beta);
        U = U + task(i).wcw / task(i).T;
        
        if U <= Ucurr
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v); 
        else
            Uprev = U - task(i).wcw / task(i).T;
            Utarget = Ucurr - Uprev;
            task(i).T = floor(task(i).wcw / Utarget);
            task(i).D = randi([task(i).len task(i).T]);
            U = Uprev + task(i).wcw / task(i).T;
            
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
            nTasks = i;
            break;
        end
        
    end
    
    % sorting by increasing relative deadlines (DEADLINE MONOTONIC)
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedRTAFP] = runRTA_FP_2(i, task(i).mksp);

        if schedRTAFP == 0
            break;
        end
    end
    
    taskGSSG = testFonsecaSAC15();
    schedMaia = testMaiaRTNS14(taskGSSG);
    
    x
        
    indexU = ceil(Ucurr / stepU);

    if schedRTAFP == 1
        vectorU_RTAFP(1, indexU) = vectorU_RTAFP(1, indexU) + 1;
    end

    if schedMaia == 1
        vectorU_Maia(1, indexU) = vectorU_Maia(1, indexU) + 1;
    end

    if schedMaia == 1 && schedRTAFP == 0
        lost = lost + 1;
    end
    
    if rem(x, save_rate) == 0
        save(workspace_name, 'x', 'lost', 'vectorU_RTAFP', 'vectorU_Maia');
    end
    
end

x = Umin : stepU : Umax - stepU;

y1 = vectorU_RTAFP;
y2 = vectorU_Maia;

figure;
plot(x, y1, '--ro', x, y2, '-.b*');
xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('RTA-FP', 'COND-SP');
