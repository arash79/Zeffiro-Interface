%ZEF_GET_SENSOR_POINTS  Load DAT xyz into zef.<current_sensors>_points.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Segmentation-tool sensors table context menu
%   **Import sensors → Points (DAT file)**: uigetfile then this script
%   (zef_menu_tool). Requires zef.file / zef.file_path already set; file==0
%   (cancel) is a no-op. zef_get_mesh(..., 'points') then
%   zef_init_sensors_parameter_profile (caller) and zef_update (caller).
%
%   See also zef_get_sensor_directions, zef_get_mesh.

if not(isequal(zef.file,0));
    zef.aux_field = zef_get_mesh(zef,[zef.file_path zef.file],zef.current_sensors,'points');
    eval(['zef.' zef.current_sensors '_points = zef.aux_field;']);
    zef = rmfield(zef,'aux_field');
end;
