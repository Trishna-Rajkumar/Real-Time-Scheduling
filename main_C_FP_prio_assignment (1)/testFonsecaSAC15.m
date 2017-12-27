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

function taskGSSG = testFonsecaSAC15()
% performs the transformation by Fonseca et al. (SAC 2015)   

    global task;
    
    paths = struct('list', {}, 'succ', {}, 'pred', {}, 'v', {});
    SSGarray = struct('SSG', {}, 'SSGhl', {});
    taskGSSG = struct('GSSG', {}, 'GSSGhl', {}, 'len', {}, 'R', {});
    
    for i = 1 : length(task)
        paths = computePaths(task(i).v);
        
        for j = 1 : length(paths)
            paths(j).v = computeFlowGraph(i, paths(j));
            
            [SSG, SSGhl] = generateSSG(paths(j).v);                                     % Algorithm 1 in the paper
            SSGarray(end + 1).SSG = SSG;
            SSGarray(end).SSGhl = SSGhl;
        end
        
        [taskGSSG(i).GSSG, taskGSSG(i).GSSGhl] = generateGSSG(SSGarray);                % Algorithm 2 in the paper
    end
    
end