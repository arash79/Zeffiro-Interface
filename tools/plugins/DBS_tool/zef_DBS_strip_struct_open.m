function zef = zef_DBS_strip_struct_open(zef)
%ZEF_DBS_STRIP_STRUCT_OPEN  Build the DBS probe window and run init.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_DBS_strip_struct_open(zef)
%
%   Called via zef_tool_start from zef_DBS_strip_struct_start.
%   Window then zef_DBS_strip_struct_init (script). Does not attach
%   electrodes.
%
%   See also zef_DBS_strip_struct_window.

zef = zef_DBS_strip_struct_window(zef);
zef_DBS_strip_struct_init; 

end
