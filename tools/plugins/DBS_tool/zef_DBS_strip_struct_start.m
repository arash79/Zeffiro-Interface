function zef = zef_DBS_strip_struct_start(zef)
%ZEF_DBS_STRIP_STRUCT_START  Open DBS probe tool (no default menu).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not in the default profile INI. Attach electrodes copies
%   strip_struct.electrode_data onto zef.<current_sensors>_points.
%
%   zef = zef_DBS_strip_struct_start(zef)
%
%   See also zef_DBS_attach_electrodes.
%

if nargin == 0
zef = evalin('base','zef');
end    

zef = zef_tool_start(zef,'zef_DBS_strip_struct_open',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end



end
