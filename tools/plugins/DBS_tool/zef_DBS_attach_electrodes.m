function zef = zef_DBS_attach_electrodes(zef)
%ZEF_DBS_ATTACH_ELECTRODES  Copy probe contacts onto current sensors.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef.<current_sensors>_points = strip_struct.electrode_data plus
%   outer/inner radius and impedance. Sets zef.sensors_visual_size.
%
%   zef = zef_DBS_attach_electrodes(zef)
%

eval(['zef.' zef.current_sensors '_points=zef.strip_struct.electrode_data;']);
eval(['zef.' zef.current_sensors '_electrode_outer_radius=zef.strip_struct.electrode_data(:,4);']);
eval(['zef.' zef.current_sensors '_electrode_inner_radius=zef.strip_struct.electrode_data(:,5);']);
eval(['zef.' zef.current_sensors '_electrode_impedance=zef.strip_struct.electrode_data(:,6);']);
zef.sensors_visual_size = zef.strip_struct.electrode_radius/2;
end
