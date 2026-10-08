function zef = zef_strip_tool_burr_toggle(zef)
%ZEF_STRIP_TOOL_BURR_TOGGLE  Show or hide burr-hole settings and restore on disable.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Switching the option off restores tetrahedra that a previous apply
%   changed, using the other leads that are still enabled. Switching it
%   on only reveals the compartment list; the mesh changes when the user
%   applies it or embeds the lead.
%
%   zef = zef_strip_tool_burr_toggle(zef)
%
%   See also zef_strip_tool_update, zef_strip_apply_burr_holes.

turning_off = isgraphics(zef.strip_tool.h_burr_hole_on) ...
    && double(zef.strip_tool.h_burr_hole_on.Value) == 0;
zef = zef_strip_tool_update(zef);
if turning_off
    [zef, report] = zef_strip_apply_burr_holes(zef, 'reapply');
    if isfield(report, 'summary') && ~isempty(report.summary)
        message = report.summary;
    else
        message = 'Create burr hole is off. Conductivity was not changed.';
    end
    zef = zef_strip_tool_burr_refresh(zef, message);
end
if isfield(zef.strip_tool, 'h_window') && isgraphics(zef.strip_tool.h_window)
    zef_layout_strip_tool(zef.strip_tool.h_window);
end

end
