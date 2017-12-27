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

function sched = testBaruahECRTS14()
% performs the test by Baruah (ECRTS 2014)   

    global m;
    
    sched = 1;
    sigmaCur = getMaxDensity();
    sigmaInc = 0.025;
    eps = 0.0000005;
    tCur = 0;
    Utot = getTotalUtilization();
    
    BOUND1 = getHyperPeriod();
    
    while 1
        if sigmaCur > (m - Utot - eps) / (m - 1)
            sched = 0;
            return;
        end
        
        BOUND2 = getTotalVolume() / (m - (m - 1) * sigmaCur - Utot);
        BOUND = min(BOUND1, BOUND2);

        TS = getTestingSet(sigmaCur, BOUND);

        for i = 1 : length(TS)
            if TS(i) >= tCur
                if work(TS(i), sigmaCur) > TS(i) * (m - (m - 1) * sigmaCur);
                    tCur = TS(i);
                    sched = 0;
                    break;
                end
            end
        end
        
        if sched == 1
            return;
        else
            sigmaCur = sigmaCur + sigmaInc;
        end    
        
    end
end