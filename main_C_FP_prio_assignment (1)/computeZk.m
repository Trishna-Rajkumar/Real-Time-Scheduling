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

function [v, Z] = computeZk(v)
% returns an upper-bound to the Z value of the task graph represented as v
% (Algorithm 2 in the paper)
    
    global m;

    order = computeTopologicalOrder(v);
    
    v(order(end)).S = order(end); 
    v(order(end)).T = order(end);
    v(order(end)).f = v(order(end)).C;
    
    for z = length(order) - 1 : -1 : 1 
        i = order(z);
        
        if ~isempty(v(i).succ)
            
            v(i).S = i;
            
            if v(i).cond == 0                                               
                
                U = zeros(1, length(v(i).succ));
                
                for j = 1 : length(v(i).succ)
                    v(i).S = union(v(i).S, v(v(i).succ(j)).S);   
                    
                    U(j) = v(v(i).succ(j)).f;
                    
                    for k = 1 : length(v(i).succ)
                        
                        if k ~= j
                            
                            C = 0;
                        
                            D = setdiff(v(v(i).succ(k)).S, v(v(i).succ(j)).T);
                            
                            for q = 1 : length(D)   
                                C = C + v(D(q)).C / m;
                            end
                        
                            U(j) = U(j) + C;
                        end
                        
                    end
                    
                end
                
                [~, uStar] = max(U);
                
                v(i).T = union(i, v(v(i).succ(uStar)).T);
                    
                v(i).f = v(i).C + U(uStar);
            else                                                           
                C = zeros(1, length(v(i).succ));
                f = zeros(1, length(v(i).succ));
                
                for j = 1 : length(v(i).succ)
                    for k = 1 : length(v(v(i).succ(j)).S)
                       C(j) = C(j) + v(v(v(i).succ(j)).S(k)).C;
                    end
                    
                    f(j) = v(v(i).succ(j)).f;
                end
                
                [~, vStar] = max(C); 
                v(i).S = union(v(i).S, v(v(i).succ(vStar)).S); 
                
                [~, uStar] = max(f);
                v(i).T = union(i, v(v(i).succ(uStar)).T);
                
                v(i).f = v(i).C + v(v(i).succ(uStar)).f;
            end
        end
    end
    
    Z = v(order(1)).f;
   
end