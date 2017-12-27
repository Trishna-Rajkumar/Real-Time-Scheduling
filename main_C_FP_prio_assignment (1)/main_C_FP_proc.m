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

workspace_name = 'FP_PROC.mat';

maxCondBranches = 2; 
maxParBranches = 6; 
p_cond = 0.4;
p_par = 0.4;
p_term = 0.2;
rec_depth = 2;
Cmin = 1;
Cmax = 100;
print = 0;
save_rate = 25;
beta = 0.1;

tasksetsPerProc = 1;
Utot = 2;
m_min = Utot;
m_max = 30;

lost = 0;

m = m_min - 1;
nTasksets = tasksetsPerProc * (m_max - m_min + 1);
addProb = 0.1;

stepM = 1;

vectorM_RTAFP = zeros(1, (m_max - m_min + 1) / stepM);
vectorM_Maia = zeros(1, (m_max - m_min + 1) / stepM);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

for x = 1 : nTasksets
    
    if rem(x - 1, tasksetsPerProc) == 0
        m = m + stepM;
    end

    U = 0;
    
    schedRTAFP = 0;
    schedMaia = 0;
    
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
        task(i).vol = computeVolume(task(i).v);

        [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
                
        task(i) = generateSchedParameters(i, beta);
        U = U + task(i).wcw / task(i).T;
        
        if U <= Utot
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v); 
        else
            Uprev = U - task(i).wcw / task(i).T;
            Utarget = Utot - Uprev;
            task(i).T = floor(task(i).wcw / Utarget);
            task(i).D = randi([task(i).len task(i).T]);
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
        
        [task(i).R, schedRTAFP] = runRTA_FP_2(i, task(i).mksp);

        if schedRTAFP == 0
            break;
        end
    end
    
    taskGSSG = testFonsecaSAC15();
    schedMaia = testMaiaRTNS14(taskGSSG);
    
    indexU = m - m_min + 1;
 
    x
        
    if schedRTAFP == 1
        vectorM_RTAFP(1, indexU) = vectorM_RTAFP(1, indexU) + 1;
    end

    if schedMaia == 1
        vectorM_Maia(1, indexU) = vectorM_Maia(1, indexU) + 1;
    end

    if schedMaia == 1 && schedRTAFP == 0
        lost = lost + 1;
    end
    
    if rem(x, save_rate) == 0
       save(workspace_name, 'vectorM_RTAFP', 'vectorM_Maia', 'x', 'lost');
    end
    
end

x = m_min : m_max;
y1 = vectorM_RTAFP;
y2 = vectorM_Maia;

figure;
plot(x, y1, '--ro', x, y2, '-.b*');
xlabel('Number of processors');
ylabel('Number of schedulable task-sets');
legend('RTA-FP', 'COND-SP');