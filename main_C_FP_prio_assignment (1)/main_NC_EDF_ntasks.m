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

workspace_name = 'EDF_NTASKS.mat';
warning('off', 'all');

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

tasksetsPerNTask = 1;
n_min = 11;
n_max = 20;
nTasks = n_min - 1;

m = 4;
nTasksets = tasksetsPerNTask * (n_max - n_min + 1);
addProb = 0.1;
Utot = 1;

stepN = 1;

vectorT_RTAEDF = zeros(1, (n_max - n_min + 1) / stepN);
vectorT_Li = zeros(1, (n_max - n_min + 1) / stepN);
vectorT_Qam = zeros(1, (n_max - n_min + 1) / stepN);
vectorT_Bar = zeros(1, (n_max - n_min + 1) / stepN);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

for x = 1 : nTasksets
    
    if rem(x - 1, tasksetsPerNTask) == 0
        nTasks = nTasks + stepN;
    end

    U = 0;
    
    schedRTAEDF = 0;
    schedLi = 0;
    schedQam = 0;
    schedBar = 0;
    
    sumU = Utot;
    
    % generation of the DAG-tasks
    for i = 1 : nTasks

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
        
        if i < nTasks
            nextSumU = sumU .* rand^(1 / (nTasks - i));
            Upart = sumU - nextSumU;
            
            while task(i).len > ceil(task(i).wcw / Upart) 
                nextSumU = sumU .* rand^(1 / (nTasks - i));
                Upart = sumU - nextSumU;
            end
            
            sumU = nextSumU;
        else
            Upart = sumU;
        end
        
        task(i) = generateSchedParametersUUniFast(i, Upart);
        
        task(i).D = task(i).T; % ADDED BECAUSE OF THE TEST OF LI ET AL. THAT REQUIRES IMPLICIT DEADLINES
        
        U = U + task(i).wcw / task(i).T;

        [~, task(i).Z] = computeZk(task(i).v); 
        [~, task(i).mksp] = computeMakespanUB(task(i).v);
    end
    
    % sorting by increasing relative deadlines (DEADLINE MONOTONIC)
    [~, ind] = sort([task.D]);
    task = task(ind);
           
    schedRTAEDF = runRTA_EDF_2();
    schedLi = testLiECRTS13();
    schedQam = testQamhiehRTNS13();
    schedBar = testBaruahECRTS14();
    
    indexU = nTasks - n_min + 1;
    
    x   
    
    if schedRTAEDF == 1
       vectorT_RTAEDF(1, indexU) = vectorT_RTAEDF(1, indexU) + 1;
    end

    if schedLi == 1
        vectorT_Li(1, indexU) = vectorT_Li(1, indexU) + 1;
    end

    if schedQam == 1
        vectorT_Qam(1, indexU) = vectorT_Qam(1, indexU) + 1;
    end

    if schedBar == 1
        vectorT_Bar(1, indexU) = vectorT_Bar(1, indexU) + 1;
    end
    
    if rem(x, save_rate) == 0
       save(workspace_name, 'vectorT_RTAEDF', 'vectorT_Bar', 'vectorT_Li', 'vectorT_Qam','x'); 
    end
end

x = n_min : n_max;
y1 = vectorT_RTAEDF;
y2 = vectorT_Bar;
y3 = vectorT_Li;
y4 = vectorT_Qam;

figure;
plot(x, y1, '--ro', x, y2, '-.b*', x, y3, '--gx', x, y4, '-.ko');
xlabel('Number of tasks');
ylabel('Number of schedulable task-sets');
legend('RTA-EDF', 'Baruah', 'Li et al.', 'Qamhieh et al.');