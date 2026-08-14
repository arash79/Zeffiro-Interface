function zef = sl1_map_estimation(zef)
%SL1_MAP_ESTIMATION  Standardized L1 (sL1) sparse inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_sl1_map_estimation
%   zef = zef_sl1_map_estimation(zef)
%
%   INI callback zef_sl1_map_estimation (Inverse tools → Standardized
%   Hierarchical L1 MAP Inversion (quadprog); default profile only).
%   Filename is zef_sl1_map_estimation.m; declared function name is
%   sl1_map_estimation. Opens the sL1 window via zef_init_sl1. Start runs
%   zef_sl1_iteration(zef). Window dump Start still names sl1_iteration
%   (overridden by init). Needs zef.L, measurements, and quadprog. Does
%   not call inverse.HALpRInverter.
%
%   See also zef_init_sl1, zef_sl1_iteration.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_init_sl1',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
