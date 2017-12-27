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

warning('off', 'all');
workspace_name = 'EDF_PROC.mat';

maxCondBranches = 2;
maxParBranches = 6;
p_cond = 0;
p_par = 0.8;
p_term = 0.2;
rec_depth = 2;
print = 0;
Cmin = 1;
Cmax = 100;
save_rate = 25;
beta = 0.1;

tasksetsPerProc = 1;
Utot = 2;
m_min = Utot; 
m_max = 30;

m = m_min - 1;
nTasksets = tasksetsPerProc * (m_max - m_min + 1);
addProb = 0.1;

stepM = 1;

vectorM_RTAEDF = zeros(1, (m_max - m_min + 1) / stepM);
vectorM_Li = zeros(1, (m_max - m_min + 1) / stepM);
vectorM_Qam = zeros(1, (m_max - m_min + 1) / stepM);
vectorM_Bar = zeros(1, (m_max - m_min + 1) / stepM);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

for x = 1 : nTasksets
    
    if rem(x - 1, tasksetsPerProc) == 0
        m = m + stepM;
    end

    U = 0;
    
    schedRTAEDF = 0;
    schedLi = 0;
    schedQam = 0;
    schedBar = 0;
   
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
        task(i).D = task(i).T; % ADDED BECAUSE OF THE TEST OF LI ET AL. THAT REQUIRES IMPLICIT DEADLINES
        
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
    
    % sorting by increasing relative deadlines (DEADLINE MONOTONIC)
    [~, ind] = sort([task.D]);
    task = task(ind);
           
    schedRTAEDF = runRTA_EDF_2();
    schedLi = testLiECRTS13();
    schedQam = testQamhiehRTNS13();
    schedBar = testBaruahECRTS14();
    
    indexU = m - m_min + 1;
    
    x
        
    if schedRTAEDF == 1
       vectorM_RTAEDF(1, indexU) = vectorM_RTAEDF(1, indexU) + 1;
    end

    if schedLi == 1
        vectorM_Li(1, indexU) = vectorM_Li(1, indexU) + 1;
    end

    if schedQam == 1
        vectorM_Qam(1, indexU) = vectorM_Qam(1, indexU) + 1;
    end

    if schedBar == 1
        vectorM_Bar(1, indexU) = vectorM_Bar(1, indexU) + 1;
    end
    
    if rem(x, save_rate) == 0
        save(workspace_name, 'vectorM_RTAEDF', 'vectorM_Li', 'vectorM_Qam', 'vectorM_Bar', 'x');
    end
    
end

x = m_min : m_max;
y1 = vectorM_RTAEDF;
y2 = vectorM_Bar;
y3 = vectorM_Li;
y4 = vectorM_Qam;

figure;
plot(x, y1, '--ro', x, y2, '-.b*', x, y3, '--gx', x, y4, '-.k*');
xlabel('Number of processors');
ylabel('Number of schedulable task-sets');
legend('RTA-EDF', 'Baruah', 'Li et al.', 'Qamhieh et al.');