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

function v = expandTaskSeriesParallel(v, source, sink, depth, numBranches, ifCond)
% returns a conditional DAG task represented as a list of vertices v, by recursively expanding blocks to either conditional/parallel branches or terminal vertices    
    
    global maxCondBranches;
    global maxParBranches;
    global p_cond;
    global p_par;
    global p_term;
    
    depthFactor = max(maxCondBranches, maxParBranches);
    horSpace = depthFactor^depth;
    
    %rng(0,'twister'); 
   
    if isempty(source) && isempty(sink)
        
        v(1).pred = [];
        v(2).succ = [];
        v(2).cond = 0;
        v(1).depth = depth;
        v(2).depth = -depth;
        v(1).width = 0;
        v(2).width = 0;
        
        if randi([1 100]) <= 50                                   
            v(1).cond = 1;
            condBranches = randi([2 maxCondBranches]);
            v = expandTaskSeriesParallel(v, 1, 2, depth - 1, condBranches, 1);
        else                        
            v(1).cond = 0;
            parBranches = randi([2 maxParBranches]);
            v = expandTaskSeriesParallel(v, 1, 2, depth - 1, parBranches, 0);
        end
    else
        
        step = horSpace / (numBranches - 1);
        w1 = (v(source).width - horSpace / 2);
        w2 = (v(sink).width - horSpace / 2);
       
        for i = 1 : numBranches
            current = length(v);
            if depth == 0
                x = 3;
            else
                r = rand;
                prob = [p_cond, p_par, p_term]; 
                x = sum(r >= cumsum([0, prob]));
            end
            
            if x == 3   % terminal vertex
                
                v(current + 1).pred = source;
                v(current + 1).succ = sink;
                v(current + 1).cond = 0;
                v(current + 1).depth = depth;
                v(current + 1).width = w1 + step * (i - 1);
                
                v(source).cond = ifCond;
                v(source).succ = [v(source).succ current + 1];
                v(sink).pred = [v(sink).pred current + 1];
                v(sink).cond = 0;
                
                if v(source).cond == 1
                    v(current + 1).condPred = [v(current + 1).condPred source];
                    v(current + 1).branchList = [v(current + 1).branchList i];
                end
                
                v(current + 1).condPred = [v(current + 1).condPred v(source).condPred];
                v(current + 1).branchList = [v(current + 1).branchList v(source).branchList];
                
            elseif x == 2   % parallel subgraph
                
                v(current + 1).pred = source;
                v(current + 1).depth = depth;
                v(current + 1).width = w1 + step * (i - 1);
               
                v(source).succ = [v(source).succ, current + 1];
                v(source).cond = ifCond;
                v(current + 2).succ = sink;
                v(current + 2).depth = -depth;
                v(current + 2).width = w2 + step * (i - 1);
                
                v(sink).pred = [v(sink).pred current + 2];
                v(sink).cond = 0;
                parBranches = randi([2 maxParBranches]);
                
                if v(source).cond == 1
                    v(current + 1).condPred = [v(current + 1).condPred source];
                    v(current + 2).condPred = [v(current + 2).condPred source];
                    
                    v(current + 1).branchList = [v(current + 1).branchList i];
                    v(current + 2).branchList = [v(current + 2).branchList i];
                end
                
                v(current + 1).condPred = [v(current + 1).condPred v(source).condPred];
                v(current + 2).condPred = [v(current + 2).condPred v(source).condPred];
                
                v(current + 1).branchList = [v(current + 1).branchList v(source).branchList];
                v(current + 2).branchList = [v(current + 2).branchList v(source).branchList];
                
                v = expandTaskSeriesParallel(v, current + 1, current + 2, depth - 1, parBranches, 0);              
                
            elseif x == 1   % conditional subgraph
                
                v(current + 1).pred = source;
                v(current + 1).depth = depth;
                v(current + 1).width = w1 + step * (i - 1);
                
                v(source).succ = [v(source).succ, current + 1];
                v(source).cond = ifCond;
                v(current + 2).succ = sink;
                v(current + 2).depth = -depth;
                v(current + 2).width = w2 + step * (i - 1);
                
                v(sink).pred = [v(sink).pred current + 2];
                v(sink).cond = 0;
                condBranches = randi([2 maxCondBranches]);
                
                if v(source).cond == 1
                    v(current + 1).condPred = [v(current + 1).condPred source];
                    v(current + 2).condPred = [v(current + 2).condPred source];
                    
                    v(current + 1).branchList = [v(current + 1).branchList i];
                    v(current + 2).branchList = [v(current + 2).branchList i];
                end
                
                v(current + 1).condPred = [v(current + 1).condPred v(source).condPred];
                v(current + 2).condPred = [v(current + 2).condPred v(source).condPred];
                
                v(current + 1).branchList = [v(current + 1).branchList v(source).branchList];
                v(current + 2).branchList = [v(current + 2).branchList v(source).branchList];
                
                v = expandTaskSeriesParallel(v, current + 1, current + 2, depth - 1, condBranches, 1);
                
            end
        end
    end
end