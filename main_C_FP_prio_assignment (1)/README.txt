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

The schedulability tests implemented are:

Global Fixed-Priority (G-FP) scheduling of conditional DAG-tasks:
[1] RTA-FP/EDF: A. Melani, M. Bertogna, V. Bonifaci, A. Marchetti-Spaccamela, G. Buttazzo, "Response-time analysis of conditional DAG tasks in multiprocessor systems" (ECRTS 2015)
[2] COND-SP: algorithm in J. C. Fonseca, V. Nelis, G. Raravi and L. M. Pinho, "A multi-DAG model for real-time parallel applications with conditional execution" (SAC 2015); schedulability test in C. Maia, M. Bertogna, L. Nogueira, L. M. Pinho, "Response-time analysis of synchronous parallel tasks in multiprocessor systems" (RTNS 2014)

Global Earliest-Deadline-First (G-EDF) scheduling of non-conditional DAG-tasks:
[3] BAR: S. Baruah, "Improved multiprocessor global schedulability analysis of sporadic DAG task systems" (ECRTS 2014)
[4] LI: J. Li, K. Agrawal, C. Lu and C. Gill, "Analysis of global EDF for parallel real-time tasks" (ECRTS 2013)
[5] QAM: M. Qamhieh, F. Fauberteau, L. George, S. Midonnet, "Global EDF scheduling of directed acyclic graphs on multiprocessor systems" (RTNS 2013)

The algorithm can be executed with the following main programs:

    - main_C_FP_U: schedulability performance wrt varying utilization
    - main_C_FP_ntasks: schedulability performance wrt varying number of tasks
    - main_C_FP_prio_assignment: schedulability performance wrt varying the priority assignment
    - main_C_FP_proc: schedulability performance wrt varying number of processors

    - main_NC_EDF_U: schedulability performance wrt varying utilization
    - main_NC_EDF_ntasks: schedulability performance wrt varying number of tasks
    - main_NC_EDF_proc: schedulability performance wrt varying number of processors
	

The parameters to be specified in the main files are:

    - workspace_name: name of the .mat file where the simulation workspace is stored
    - maxCondBranches: maximum number (>= 2) of branches in a conditional statement
    - maxParBranches: maximum number (>= 2) of branches in a parallel statement
    - p_cond: probability of generating a conditional branch (s.t. p_cond + p_par + p_term = 1)
    - p_par: probability of generating a parallel branch (s.t. p_cond + p_par + p_term = 1)
    - p_term: probability of generating a terminal vertex (s.t. p_cond + p_par + p_term = 1)
    - rec_depth: maximum recursion depth for the generation of the task graphs
    - Cmin: minimum worst-case execution time of a vertex
    - Cmax: maximum worst-case execution time of a vertex
    - beta: minimum utilization of each DAG-task
    - tasksetsPerX: number of task-sets to be generated for each value on the x-axis
    - addProb: probability to add an edge between pairs of vertices that can be connected (to transform a series-parallel graph into a DAG)
	- m: number of processors (whenever fixed)
    - U: utilization of the task-set (whenever fixed)
    - Xmin, Xmax: minimum/maximum values for X of each task-set (whenever not fixed)
    - lost: number of task-sets schedulable by COND-SP but not by RTA-FP
    - stepX: step in the variation of X
    - save_rate: number of iterations to save the workspace
    - print: enable (1) or disable (0) printing of the task-sets

The execution of the program produces plots of schedulability results, saving the simulation workspace in the user-specified .mat file.