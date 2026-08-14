%ZEF_PLOT_VOLUME  Leftover filename zef_plot_volume.m.m; not the volume plotter.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MATLAB does not execute .m.m files. Body: if zef.file is not
%   0, zef_get_mesh(..., current_sensors, 'points') into
%   zef.<current_sensors>_points. Volume drawing is zef_plot_volume.m.
%
%   See also zef_plot_volume.
if not(isequal(zef.file,0));
    zef.aux_field = zef_get_mesh(zef,[zef.file_path zef.file],zef.current_sensors,'points');
    eval(['zef.' zef.current_sensors '_points = zef.aux_field;']);
    zef = rmfield(zef,'aux_field');
end;
