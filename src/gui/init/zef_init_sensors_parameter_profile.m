%ZEF_INIT_SENSORS_PARAMETER_PROFILE  Pad per-sensor profile arrays to point count (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. For enabled Sensors parameter_profile rows, if
%   zef.<current_sensors>_<param> row count ≠ *_points, fills the array
%   with profile default (column 4) via evalin on base zef. Called from
%   zef_init_sensor_parameters before building the parameters table.
%
%   See also zef_init_sensor_parameters, zef_init_parameter_profile.
for zef_j = 1 : size(zef.parameter_profile,1)
    if isequal(zef.parameter_profile{zef_j,8},'Sensors') && isequal(zef.parameter_profile{zef_j,6},'On') && isequal(zef.parameter_profile{zef_j,7},'On')
        if not(isequal(evalin('base', ['size(zef.' zef.current_sensors '_points,1)']),evalin('base', ['size(zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} ',1)'])))
            if isequal(zef.parameter_profile{zef_j,3},'Scalar')
                evalin('base', ['zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} '=' num2str(zef.parameter_profile{zef_j,4}) '*ones(size(zef.' zef.current_sensors '_points,1),1);']);
            elseif isequal(zef.parameter_profile{zef_j,3},'String')
                evalin('base', ['zef.' zef.current_sensors '_' zef.parameter_profile{zef_j,2} '=' (zef.parameter_profile{zef_j,4}) '*ones(size(zef.' zef.current_sensors '_points,1),1);']);
            end
        end
    end
end
