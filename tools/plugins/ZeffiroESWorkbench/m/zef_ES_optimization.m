function zef_ES_optimization(zef)
%ZEF_ES_OPTIMIZATION  Open Inverse tools → ES Workbench.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Menu callback from profile/*/zeffiro_plugins.ini (label "ES Workbench",
%   parent inverse_tools). Temporarily sets font_size to 14, then
%   zef_tool_start(..., 'zef_ES_optimization_window', ...). tES electrode
%   currents (not MEG/EEG inverse). Needs zef.L and zef.inv_synth_source.
%   With no input, reads base-workspace zef; with no output, writes it back.
%
%   zef_ES_optimization(zef)
%
%   See also zef_ES_optimization_window, zef_ES_find_currents.
%

if nargin == 0
    zef = evalin('base','zef');
end

org_val         = zef.font_size;
zef.font_size   = 14;
zef             = zef_tool_start(zef, 'zef_ES_optimization_window', 1/5, 1);
zef.font_size   = org_val;

if nargout == 0
    assignin('base','zef',zef);
end

end
