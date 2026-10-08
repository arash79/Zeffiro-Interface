function zef_strip_burr_dialogs(zef, report)
%ZEF_STRIP_BURR_DIALOGS  Show one OK dialog for pending burr-hole notices.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Dialogs are shown only when zef.use_display is true, so mesh
%   generation and unit tests without a display do not block. Several
%   notices are combined into one window.
%
%   zef_strip_burr_dialogs(zef, report)
%
%   See also zef_strip_burr_notice, zef_strip_apply_burr_holes.

if nargin < 2 || ~isstruct(report) || ~isfield(report, 'dialogs') || isempty(report.dialogs)
    return
end
if ~isstruct(zef) || ~isfield(zef, 'use_display') || ~logical(zef.use_display)
    return
end
parts = cell(1, numel(report.dialogs));
for i = 1:numel(report.dialogs)
    parts{i} = char(string(report.dialogs(i).message));
end
message = strjoin(parts, sprintf('\n\n'));
if isempty(strtrim(message))
    return
end
zef_strip_burr_notice(message);

end
