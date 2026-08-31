%ZEF_SNAPSHOT_MOVIE  Mesh visualization **Frame / Movie** (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Wired from zef_mesh_visualization_tool onto h_pushbutton22
%   (App Designer Text='Frame / Movie'). uiputfile for *.jpg / *.tif /
%   *.png / *.avi into zef.save_file_path. Cancel (file==0) returns.
%   Otherwise zef_process_meshes(zef, zef.explode_everything) then
%   zef_print_meshes([]), which writes zef.file using zef.file_index
%   (jpg/tif/png still or VideoWriter avi). Frame range is
%   zef.frame_start / frame_stop / frame_step from the same tool.
%
%   See also zef_print_meshes, zef_play_cdata, zef_store_cdata.
[zef.file zef.file_path zef.file_index] = uiputfile({'*.jpg';'*.tif';'*.png';'*.avi'},'Save visualization as...',zef.save_file_path);
if not(isequal(zef.file,0));
    zef_process_meshes(zef,zef.explode_everything);
    zef_print_meshes([]);
end;
