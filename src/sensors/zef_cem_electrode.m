function s_points = zef_cem_electrode(zef,s_points)
%ZEF_CEM_ELECTRODE  Append CEM radii and impedance columns to sensor xyz.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Registered in profile/*/zeffiro_init.ini as
%     "CEM electrode creation", @zef_cem_electrode, create_patch_sensor
%   zef_process_meshes calls zef.create_patch_sensor(zef, s_points) when
%   imaging_method==1 (EEG) and the handle is non-empty.
%
%   Reads zef.<current_sensors>_electrode_outer_radius, _inner_radius,
%   _electrode_impedance. Scalars are replicated to N rows. A vector left
%   short by append-contacts is aligned with zef_electrode_property_column.
%   Returns [x y z outer_radius inner_radius impedance]. Empty s_points → [].
%
%   s_points = zef_cem_electrode(zef, s_points)
%
%   See also zef_process_meshes, zef_pem2cem.

if isempty(s_points)
    s_points = [];
else
    current_sensors = eval('zef.current_sensors');
    
    % Get the number of sensor points
    n_sensors = size(s_points, 1);
    
    outer_radius = zef_electrode_property_column( ...
        eval(['zef.' current_sensors '_electrode_outer_radius']), n_sensors);
    inner_radius = zef_electrode_property_column( ...
        eval(['zef.' current_sensors '_electrode_inner_radius']), n_sensors);
    impedance = zef_electrode_property_column( ...
        eval(['zef.' current_sensors '_electrode_impedance']), n_sensors);

    s_points = [s_points(:,1:3), outer_radius, inner_radius, impedance];
end
end
