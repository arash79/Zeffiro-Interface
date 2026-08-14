function zef = zef_ramus_inversion_tool(zef)
%ZEF_RAMUS_INVERSION_TOOL  RAMUS hierarchical Bayesian sparse inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_ramus_inversion_tool
%   zef = zef_ramus_inversion_tool(zef)
%
%   INI callback (Inverse tools → RAMUS Inversion). Opens the RAMUS window
%   via zef_ramus_window. Start runs zef_ramus_iteration(zef). Create
%   multiresolution decomposition must fill ramus_multires_dec first.
%   Needs zef.L and zef.measurements. Does not call inverse.RAMUSInverter.
%
%   See also zef_ramus_window, zef_ramus_iteration.
%

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_ramus_window',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
