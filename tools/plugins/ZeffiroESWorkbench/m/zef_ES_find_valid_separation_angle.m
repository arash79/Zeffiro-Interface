function angles_list = zef_ES_find_valid_separation_angle
%ZEF_ES_FIND_VALID_SEPARATION_ANGLE  List separation angles that still yield five distinct 4×1 sensors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not bound in zef_ES_optimization_window. Loops 0:359° through
%   zef_ES_4x1_sensors and keeps angles whose five indices are unique.
%   Returns a table (Separation Angle, O, P1–P4).
%
%   angles_list = zef_ES_find_valid_separation_angle
%
%   See also zef_ES_4x1_sensors.
%

ell = zeros(360,6);
for i = 0:359;
    ell(i+1) = i;
    ell(i+1,2:6) = zef_ES_4x1_sensors(i);
    ell(i+1,7) = length(ell(i+1,2:6)) == length(unique(ell(i+1,2:6)));
end
angles_list = ell(find(ell(:,7)),1:6); %#ok<FNDSB>
angles_list = array2table(angles_list(:,1:6),'Variablenames',{'Separation Angle','O','P1','P2','P3','P4'});
end
