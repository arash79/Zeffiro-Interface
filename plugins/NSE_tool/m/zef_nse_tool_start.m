function zef = zef_nse_tool_start(zef)
%ZEF_NSE_TOOL_START  Open Multi tools → NSE tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Menu callback from profile/*/zeffiro_plugins.ini (label "NSE tool",
%   parent multi_tools). zef_tool_start(..., 'zef_nse_tool_window', ...).
%   Hemodynamic Poisson / NSE window. Solve system runs zef_nse_run_solver
%   (src/forward/nse); results on zef.nse_field. Does not write zef.L.
%   solver_type 3 uses zef_nse_haemodynamic_response_solver in this plugin.
%
%   zef = zef_nse_tool_start()
%   zef = zef_nse_tool_start(zef)
%
%   See also zef_nse_tool_window, zef_nse_run_solver.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_nse_tool_window',2/3,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
