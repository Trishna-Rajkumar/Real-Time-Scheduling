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

function plotCircle(x, y, r, i, v)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step
    
    ang = 0 : 0.01 : 2 * pi; 
    xp = r * cos(ang);
    yp = r * sin(ang);
    plot(x + xp, y + yp);
    
    str = strcat('v', num2str(i));
    
    text(x + r + 0.05, y + r + 0.05, str);
    
    str2 = num2str(v(i).C);
    text(x - r - 0.1, y - r - 0.1, str2);
end