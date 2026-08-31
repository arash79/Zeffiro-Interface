function h = zef_ui_find(parent, tag)
%ZEF_UI_FIND  First descendant of parent whose Tag matches.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Caches the handle on the search parent so layout can reposition
%   without a full descendant scan on every SizeChanged event.
%
%   h = zef_ui_find(parent, tag)

h = gobjects(0);
if nargin < 2 || isempty(parent) || ~isgraphics(parent) || ~isvalid(parent)
    return
end
tag = char(string(tag));
key = ['ZefFind_' regexprep(tag, '[^A-Za-z0-9_]', '_')];
try
    if isappdata(parent, key)
        h = getappdata(parent, key);
        if ~isempty(h) && isgraphics(h) && isvalid(h)
            return
        end
    end
catch
end
found = findall(parent, 'Tag', tag);
for i = 1:numel(found)
    try
        if isgraphics(found(i)) && isvalid(found(i))
            h = found(i);
            try
                setappdata(parent, key, h);
            catch
            end
            return
        end
    catch
    end
end

end
