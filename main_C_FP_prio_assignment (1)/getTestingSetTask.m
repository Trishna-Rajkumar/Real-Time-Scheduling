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

function TS = getTestingSetTask(ind, sigma, bound)
% used for the test by Baruah

    global task;
    lambdaSet = [];
    tLambdaUp = [];
    tLambdaDown = [];
    
    lTable = [];
    TS = [];
    
    %------------------BUILD THE SET OF LAMBDAs------------------%
    
    for i = 1 : length(task(ind).v)
        tLambdaUp = [tLambdaUp localOffset(task(ind), i)]; 
        tLambdaDown = [tLambdaDown (localOffset(task(ind), i) + task(ind).v(i).C)];
    end
    
    tLambdaUp = sort(tLambdaUp);
    tLambdaDown = sort(tLambdaDown);
    
    lTable = [0  1];
    
    for i = 2 : length(tLambdaUp)
        
        [pres, loc] = ismember(tLambdaUp(i), lTable(:,1));
        
        if pres == 1
            lTable(loc, 2) = lTable(loc, 2) + 1;
        else
            lTable = [lTable; [tLambdaUp(i) 1] ];
        end
    end
    
    for i = 2 : length(lTable)
        lTable(i, 2) = lTable (i, 2) + lTable(i - 1, 2);
    end
    
    for i = 1 : length(tLambdaDown)
        [pres, loc] = ismember(tLambdaDown(i), lTable(:,1));
        
        if pres == 1
            lTable(loc, 2) = lTable(loc, 2) - 1;
            
            for j = loc + 1 : length(lTable)
                lTable(j, 2) = lTable(j, 2) - 1;
            end
        else
            lev = 0;
            for j = 1 : length(lTable)
                if lTable(j, 1) <= tLambdaDown(i)
                    lev = j;
                end
            end
            
            for j = lev + 1 : length(lTable)
                lTable(j, 2) = lTable(j, 2) - 1;
            end    
            
            lTable(end + 1, :) = [tLambdaDown(i) lTable(lev, 2) - 1];
            
            lTable = sortrows(lTable, 1);
        end
    end
    
    lambdaSet = lTable(1, 1);
    
    for i = 2 : length(lTable)
        if lTable(i, 2) ~= lTable(i - 1, 2)
            lambdaSet = [lambdaSet lTable(i, 1)];
        end
    end
    
    %------------------BUILD THE TESTING SET OF THE TASK------------------%
    
    n = 0;
    exit = 0;
    
    while 1
        newV = (lambdaSet / sigma) + n * task(ind).T;
        
        for i = 1 : length(newV)
            if newV(i) <= bound
                TS = [TS newV(i)];
            else
                exit = 1;
                break;
            end
            
        end
        
        if exit == 1
            break;
        end
        
        n = n + 1;
        
    end
        
end