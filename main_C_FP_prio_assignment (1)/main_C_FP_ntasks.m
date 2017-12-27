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
% making a combined work based on this code. Thus, the terms and
% conditions of the GNU General Public License cover the whole
% combination.
%
% cptasks is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
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
global root;
global leaf;
global final_dag;
% global paths;
global task_num; 
global intermediate_dag
global test_dag;
global forbidden_pair;
test=1;
workspace_name = 'FP_NTASKS.mat';
maxCondBranches = 2;
maxParBranches = 2;

p_cond = 0;
p_par = 0.5;
p_term = 0.5;
task_num=1; % must be always 1 for PL-DAG implementation as we consider only 1DAG
rec_depth = 4;
Cmin = 1;
Cmax = 100;
tasksetsPerNTask = 1;
n_min = 1;
n_max = 1;
nTasks = n_min - 1;
m = 3;
nTasksets = tasksetsPerNTask * (n_max - n_min + 1);
addProb = 0.1;
Utot = 2;
save_rate = 25;
print = 1;
lost = 0;
stepN = 1;
vectorT_RTAFP = zeros(1, (n_max - n_min + 1) / stepN);
vectorT_Maia = zeros(1, (n_max - n_min + 1) / stepN);

intermediate_dag = struct('v1', {}, 'path_num', {},'paths_n',{}, 'path_weight', {}, 'load_diff_inter', {},'selection_factor',{});
final_dag = struct('pl_dag', {}, 'path_num', {},'paths_n',{}, 'path_weight', {}, 'load_diff_inter', {},'selection_factor',{});

v1 = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {},'forbidden', {});
        
task = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {},'paths',{}, 'path_weights',{});
for x = 1 : nTasksets
    if rem(x - 1, tasksetsPerNTask) == 0
        nTasks = nTasks + stepN;
    end
    U = 0;
    schedRTAFP = 0;
    schedMaia = 0;
    sumU = Utot;
    % generation of the DAG-tasks
    for i = 1 : nTasks
         v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {},'forbidden', {});
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
        U = U + task(i).wcw / task(i).T;
        [~, task(i).Z] = computeZk(task(i).v);
        [~, task(i).mksp] = computeMakespanUB(task(i).v);
    end
end
task(1).v(1)

%to be removed
            load('test3.mat')
           
            printTask(task(1).v);
%to be removed

%%%%%% check if paths> m%%%%%%%%%%%%%
for x = 1:length(task(task_num).v)
    if (isempty(task(task_num).v(x).pred))
        root= x;
    else
    if (isempty(task(task_num).v(x).succ))
        leaf= x;
    end
    end
end

%%%%%%%%%% direct path btw root and leaf removed as it is redundant when
%%%%%%%%%% there are multiple paths connecting the two%%%%%%%%%%%%%%
if (length(task(task_num).v(leaf).pred)>1 && ismember(root,task(task_num).v(leaf).pred))
    task(task_num).v(leaf).pred( task(task_num).v(leaf).pred==root)=[];
    task(task_num).v(root).succ( task(task_num).v(root).succ==leaf)=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[~,adj_m ]= sparse_adj_WeightedEdges(task(task_num).v);
paths= pathbetweennodes(adj_m,root,leaf,false);
path_wt= path_weights_func(task(task_num).v,paths);
load_diff= max(path_wt)-min(path_wt);


task(task_num).paths=paths;
task(task_num).path_weights=path_wt

for par=1:length(task(task_num).v) %initialisation to avoid evaluating empty vector while setting constraints
    task(task_num).v(par).forbidden=0;
end

if(length(paths)>m)
    intermediate_dag(task_num).v1= task(task_num).v;
    set_artificial_constraints(intermediate_dag(task_num).v1);
else
    final_dag(task_num).pl_dag=task(task_num).v;
    printTask(final_dag(task_num).pl_dag);
    title('Given DAG needs no path reduction')
end

   
   
%     set_artificial_constraints(intermediate_dag(task_num).v1);




