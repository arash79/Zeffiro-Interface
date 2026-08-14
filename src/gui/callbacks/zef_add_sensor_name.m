%ZEF_ADD_SENSOR_NAME  Append one blank sensor row to the current sensor set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Right-click the Sensors UITable (per-electrode/coil names) →
%   **Add sensor** (h_menu_add_sensors; MenuSelectedFcn is
%   "zef_add_sensor_name;"). Does nothing when zef.lock_sensor_names_on
%   is true (**Lock on** on that table).
%
%   Script (not a function). All writes go through evalin('base',...).
%
%   What it does (current_sensors tag)
%     - If <tag>_points has 6 columns or is empty, appends
%       [0 0 0 0 1 default_impedance_value] (CEM-style xyz + extras).
%       Otherwise appends [0 0 0].
%     - If <tag>_imaging_method_name is Vector field or Vector field
%       gradient (imaging_method_cell{2} or {3}), also appends a
%       directions row: 6 zeros if that array is N×6, else 3 zeros.
%     - For each parameter_profile row with domain Sensors, columns 6
%       and 7 both 'On': appends one Scalar or String default (column 4)
%       onto zef.<tag>_<column-2-name>.
%     - zef_init_sensors_name_table rebuilds the name table.
%
%   See also zef_delete_sensors, zef_toggle_lock_sensor_names_on.

if not(evalin('base','zef.lock_sensor_names_on'))

    if ismember(evalin('base',['size(zef.' zef.current_sensors '_points,2)']),[6,0])
        evalin('base',['zef.' zef.current_sensors '_points = [zef.' zef.current_sensors '_points; [0 0 0 0 1 ' num2str(evalin('base','zef.default_impedance_value')) ' ]];']);
    else
        evalin('base',['zef.' zef.current_sensors '_points = [zef.' zef.current_sensors '_points; [0 0 0]];']);
    end

    if ismember(evalin('base',['zef.' zef.current_sensors '_imaging_method_name']),{evalin('base',['zef.imaging_method_cell{2}']),evalin('base',['zef.imaging_method_cell{3}'])})

        if evalin('base',['size(zef.' zef.current_sensors '_directions,2)']) == 6
            evalin('base',['zef.' zef.current_sensors '_directions = [zef.' zef.current_sensors '_directions; [0 0 0 0 0 0]];']);
        else
            evalin('base',['zef.' zef.current_sensors '_directions = [zef.' zef.current_sensors '_directions; [0 0 0]];']);
        end

    end

    for zef_i = 1 : size(zef.parameter_profile,1)

        if isequal(zef.parameter_profile{zef_i,8},'Sensors') && isequal(zef.parameter_profile{zef_i,6},'On') && isequal(zef.parameter_profile{zef_i,7},'On')
            if isequal(zef.parameter_profile{zef_i,3},'Scalar')
                evalin('base',['zef.' zef.current_sensors '_' zef.parameter_profile{zef_i,2} '(size(zef.' zef.current_sensors '_' zef.parameter_profile{zef_i,2} ',1)+1) =' num2str(zef.parameter_profile{zef_i,4}) ';']);
            elseif isequal(zef.parameter_profile{zef_i,3},'String')
                evalin('base',['zef.' zef.current_sensors '_' zef.parameter_profile{zef_i,2} '(size(zef.' zef.current_sensors '_' zef.parameter_profile{zef_i,2} ',1)+1) =' zef.parameter_profile{zef_i,4} ';']);
            end
        end

    end

    clear zef_i;

    zef_init_sensors_name_table;

end
