function h = zef_ui_find(parent, tag)
%ZEF_UI_FIND  First descendant of parent whose Tag matches.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   h = zef_ui_find(parent, tag)

h = gobjects(0);
if nargin < 2 || isempty(parent) || ~isgraphics(parent) || ~isvalid(parent)
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
