function zef = zef_ui_tag_handles(zef)
%ZEF_UI_TAG_HANDLES  Copy zef field names onto empty widget Tags.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   App Designer exports often leave Tag blank. Layout helpers look up
%   controls by Tag, so fill it from the zef field name when empty.
%
%   zef = zef_ui_tag_handles(zef)
%
%   See also zef_ui_ready.

if nargin < 1 || ~isstruct(zef)
    return
end

names = fieldnames(zef);
for i = 1:numel(names)
    obj = zef.(names{i});
    if isempty(obj) || ~isscalar(obj)
        continue
    end
    try
        if ~ishghandle(obj)
            continue
        end
    catch
        continue
    end
    try
        if ~isvalid(obj)
            continue
        end
    catch
        continue
    end
    try
        if ~isprop(obj, 'Tag')
            continue
        end
        current = strtrim(char(string(obj.Tag)));
        if isempty(current)
            obj.Tag = names{i};
        end
    catch
    end
end

end
