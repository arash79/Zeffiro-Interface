function h = zef_ui_control(h_parent, tag)
%ZEF_UI_CONTROL  Live tagged control, including sidebar descendants.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Figure-tool sliders and popups now live inside the sidebar panel, so
%   findobj(figure.Children, Tag=...) returns empty. findall is required,
%   but must skip deleted GraphicsPlaceholder entries. If the control is
%   not on h_parent (popped-out axes figure), fall back to zef.h_zeffiro
%   where the widgets actually live.
%
%   h = zef_ui_control(h_parent, tag)
%
%   See also zef_ui_find, zef_ui_axes, zef_figure_tool.

h = gobjects(0);
if nargin < 2 || isempty(tag)
    return
end
h = local_valid(h_parent, tag);
if local_ok(h)
    return
end
try
    zef = evalin('base', 'zef');
    if isstruct(zef) && isfield(zef, 'h_zeffiro') ...
            && ~isequal(h_parent, zef.h_zeffiro)
        h = local_valid(zef.h_zeffiro, tag);
    end
catch
end

end

function h = local_valid(parent, tag)

h = gobjects(0);
if isempty(parent)
    return
end
try
    if ~isgraphics(parent) || ~isvalid(parent)
        return
    end
catch
    return
end
found = findall(parent, 'Tag', tag);
for i = 1:numel(found)
    try
        if isgraphics(found(i)) && isvalid(found(i))
            h = found(i);
            return
        end
    catch
    end
end

end

function tf = local_ok(h)

tf = false;
try
    tf = ~isempty(h) && isgraphics(h) && isvalid(h);
catch
end

end
