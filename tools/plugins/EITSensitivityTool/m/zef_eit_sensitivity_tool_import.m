%ZEF_EIT_SENSITIVITY_TOOL_IMPORT  uigetfile *.mat → zef.eit_sensitivity_tool_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Import interpolation (first file). load() of the mat into
%   eit_sensitivity_tool_data; stores the path on
%   eit_sensitivity_tool_file and the filename widget. Cancel is a
%   no-op. Does not write reconstruction.
%
%   See also zef_eit_sensitivity_tool_import_2.

[zef.file zef.file_path] = uigetfile({'*.mat'},'Import interpolation',zef.save_file_path);
if not(isequal(zef.file,0));
    [zef.eit_sensitivity_tool_data] = load([zef.file_path zef.file]);
    zef.eit_sensitivity_tool_file = [zef.file_path zef.file];
    set(zef.h_eit_sensitivity_tool_file, 'Value', zef.eit_sensitivity_tool_file);
end
