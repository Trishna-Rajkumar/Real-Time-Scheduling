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

workspace_name = 'FP_PRIO.mat';
largest_integer = 2^53 - 1;

maxCondBranches = 2; 
maxParBranches = 6;
p_cond = 0.4;
p_par = 0.4;
p_term = 0.2;
Cmin = 1;
Cmax = 100;
beta = 0.1;

tasksetsPerU = 1;
addProb = 0.1;
m = 4;
lost = 0;
rec_depth = 2;
print = 0;

Umin = 0;
Umax = 4;
stepU = 0.25;

nTasksets = tasksetsPerU * ((Umax - Umin)/stepU);

vectorU_DM = zeros(1, (Umax - Umin) / stepU);
vectorU_SB1 = zeros(1, (Umax - Umin) / stepU);
vectorU_SB2 = zeros(1, (Umax - Umin) / stepU);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

U = 0;
Ucurr = Umin;

for x = 1 : nTasksets

    if rem(x - 1, tasksetsPerU) == 0
        Ucurr = Ucurr + stepU;
    end
    U = 0;
   
    schedOurDM = 0;
    schedOurSB1 = 0;
    schedOurSB2 = 0;
    
    i = 0;
    
    % generation of the DAG-tasks
    while 1
        
        i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});

        v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = v;
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
            task(i).D = randi([min(largest_integer, task(i).len) min(largest_integer, task(i).T)]);
            U = Uprev + task(i).wcw / task(i).T;
            
            [~, task(i).Z] = computeZk(task(i).v);
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
            nTasks = i;
            break;
        end
        
    end
    
    % sorting by increasing relative deadlines
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedOurDM] = runRTA_FP_2(i, task(i).mksp);

        if schedOurDM == 0
            break;
        end
    end
    
    % sorting by increasing values of (D_k - W_k) (WS)
    for i = 1 : nTasks
        task(i).R = [];
    end
    
    W = [task(:).wcw];
    D = [task(:).D];
    [~, ind] = sort(D - (W / m));
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedOurSB1] = runRTA_FP_2(i, task(i).mksp);

        if schedOurSB1 == 0
            break;
        end
    end
    
    % sorting by increasing values of (D_k - L_k) (LS)
    for i = 1 : nTasks
        task(i).R = [];
    end
    
    D = [task(:).D];
    L = [task(:).len];
    [~, ind] = sort(D - L);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedOurSB2] = runRTA_FP_2(i, task(i).mksp);

        if schedOurSB2 == 0
            break;
        end
    end
    
    x
        
    indexU = ceil(Ucurr / stepU);

    if schedOurDM == 1
        vectorU_DM(1, indexU) = vectorU_DM(1, indexU) + 1;
    end

    if schedOurSB1 == 1
        vectorU_SB1(1, indexU) = vectorU_SB1(1, indexU) + 1;
    end

    if schedOurSB2 == 1
        vectorU_SB2(1, indexU) = vectorU_SB2(1, indexU) + 1;
    end
    
    if rem(x, 100) == 0
        save(workspace_name, 'x', 'vectorU_DM', 'vectorU_SB1', 'vectorU_SB2');
    end
    
end

x = Umin : stepU : Umax - stepU;

y1 = vectorU_DM;
y2 = vectorU_SB1;
y3 = vectorU_SB2;

figure;
plot(x, y1, '--ro', x, y2, '-.b*', x, y3, '--gx');
xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('DM', 'WS', 'LS');