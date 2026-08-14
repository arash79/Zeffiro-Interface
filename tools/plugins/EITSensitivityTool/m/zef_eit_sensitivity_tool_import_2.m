%ZEF_EIT_SENSITIVITY_TOOL_IMPORT_2  uigetfile *.mat → zef.eit_sensitivity_tool_data_2.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Second interpolation file (comparison / dual map). Same
%   load path as import 1 onto eit_sensitivity_tool_data_2 / _file_2.
%   Does not write reconstruction.
%
%   See also zef_eit_sensitivity_tool_import.

[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef.save_file_path);
if not(isequal(zef.file,0));
    [zef.eit_sensitivity_tool_data_2] = load([zef.file_path zef.file]);
    zef.eit_sensitivity_tool_file_2 = [zef.file_path zef.file];
    set(zef.h_eit_sensitivity_tool_file_2, 'Value', zef.eit_sensitivity_tool_file_2);
end
