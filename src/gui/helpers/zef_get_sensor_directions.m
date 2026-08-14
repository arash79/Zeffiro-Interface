%ZEF_GET_SENSOR_DIRECTIONS  Load DAT directions into zef.<current_sensors>_directions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. **Import sensors → Directions (DAT file)** on the sensors table.
%   Uses zef_get_mesh(..., 'triangles') — that file_type means "load a
%   numeric array as connectivity/directions", not triangle meshing.
%   Cancel (zef.file==0) is a no-op. MEG needs directions; EEG typically not.
%
%   See also zef_get_sensor_points, zef_get_mesh.

if not(isequal(zef.file,0));
    zef.aux_field = zef_get_mesh(zef,[zef.file_path zef.file],zef.current_sensors,'triangles');
    eval(['zef.' zef.current_sensors '_directions = zef.aux_field;']);
    zef = rmfield(zef,'aux_field');
end;
