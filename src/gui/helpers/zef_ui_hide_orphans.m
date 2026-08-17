function zef_ui_hide_orphans(fig)
%ZEF_UI_HIDE_ORPHANS  Hide leftover App Designer widgets after a grid rebuild.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   After reparenting into zef_ui_root, anything still parented to the
%   figure is an unused absolute-positioned leftover. Hide it so it
%   cannot punch a hole in the new layout.
%
%   zef_ui_hide_orphans(fig)

if nargin < 1 || isempty(fig) || ~isgraphics(fig) || ~isvalid(fig)
    return
end
root = findall(fig, 'Tag', 'zef_ui_root');
if isempty(root)
    return
end
root = root(1);
kids = [];
try
    kids = fig.Children;
catch
    return
end
for i = 1:numel(kids)
    obj = kids(i);
    if isempty(obj) || ~isvalid(obj) || obj == root
        continue
    end
    try
        if isprop(obj, 'Tag') && strcmp(char(obj.Tag), 'zef_ui_root')
            continue
        end
    catch
    end
    try
        obj.Visible = 'off';
    catch
    end
end

end
