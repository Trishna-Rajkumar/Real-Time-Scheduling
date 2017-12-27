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

function [GSSG, GSSGhl] = generateGSSG(SSGarray)
% generates a GSSG for a task (used in the test by Fonseca et al.)

    cutSSGs = [];
    indexOfSegment = ones(1, length(SSGarray));
    GSSGhl = [];
    GSSG = struct('C', {}, 'pred', {}, 'succ', {}, 'depth', {}, 'width', {}, 'cond', {}, 'accWorkload', {});
    prevLen = 0;
    addedNew = 0;
    
    while length(cutSSGs) ~= length(SSGarray)
        bMin = Inf;
        qMax = 0;
        
        for i = 1 : length(SSGarray)
            if ~ismember(i, cutSSGs)
               
                sigmaCurr(i, :) = SSGarray(i).SSGhl(indexOfSegment(i), :);
                bCurr(i) = sigmaCurr(i, 1);
                qCurr(i) = sigmaCurr(i, 2);
                if bMin > bCurr(i)
                    bMin = bCurr(i);
                end
                
                if qMax < qCurr(i)
                    qMax = qCurr(i);
                end
            end
        end
        
        GSSGhl = [GSSGhl; [bMin, qMax]];
        
        for i = 1 : length(SSGarray)
            if ~ismember(i, cutSSGs)
                if bCurr(i) - bMin == 0
                    indexOfSegment(i) = indexOfSegment(i) + 1;
                else
                    SSGarray(i).SSGhl(indexOfSegment(i), 1) = SSGarray(i).SSGhl(indexOfSegment(i), 1) - bMin;
                end    

                if indexOfSegment(i) > length(SSGarray(i).SSGhl)
                    cutSSGs = [cutSSGs i];
                end
            end
        end
        
    end 
    
    for i = 1 : length(GSSGhl)
        for j = 1 : GSSGhl(i, 2)
            GSSG(end + 1).C = GSSGhl(i, 1);
            GSSG(end).pred = prevLen - addedNew + 1 : prevLen;
            GSSG(end).depth = -i;
            GSSG(end).width = j;
            GSSG(end).cond = 0;
        end
        
        for j = prevLen - addedNew + 1 : prevLen
            GSSG(j).succ = prevLen + 1 : prevLen + GSSGhl(i, 2);
        end
        
        prevLen = length(GSSG);
        addedNew = GSSGhl(i, 2);
    end    
end