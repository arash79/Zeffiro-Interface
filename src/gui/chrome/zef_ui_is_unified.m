function tf = zef_ui_is_unified(h)
%ZEF_UI_IS_UNIFIED  True when the figure hosts the unified application shell.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   tf = zef_ui_is_unified
%   tf = zef_ui_is_unified(h)
%
%   See also zef_ui_shell, zef_figure_tool.

tf = false;
if nargin < 1 || isempty(h)
    h = [];
    try
        zef = evalin('base', 'zef');
        if isstruct(zef) && isfield(zef, 'h_zeffiro')
            h = zef.h_zeffiro;
        end
    catch
    end
end
if isempty(h) || ~isgraphics(h) || ~isvalid(h)
    return
end
try
    tf = ~isempty(zef_ui_find(h, 'zef_shell_nav')) ...
        || isequal(getappdata(h, 'ZefUnifiedShell'), true);
catch
end

end
