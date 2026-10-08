function zef = zef_strip_tool_burr_apply(zef)
%ZEF_STRIP_TOOL_BURR_APPLY  Commit widgets and write burr-hole conductivity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_tool_burr_apply(zef)
%
%   See also zef_strip_apply_burr_holes.

zef = zef_strip_tool_update(zef);
[zef, report] = zef_strip_apply_burr_holes(zef, zef_strip_burr_mode('apply'));
if isfield(report, 'summary') && ~isempty(report.summary)
    message = report.summary;
else
    message = 'Burr-hole apply finished.';
end
zef = zef_strip_tool_burr_refresh(zef, message);
zef_strip_burr_dialogs(zef, report);

end
