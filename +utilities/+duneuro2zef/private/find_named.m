function val = find_named(s, names, max_depth)
%FIND_NAMED  First nonempty field matching names, searching nested structs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    val = [];
    if ~isstruct(s) || isempty(s)
        return
    end
    if nargin < 3
        max_depth = 2;
    end
    val = find_named_depth(s, names, max_depth, 0);
end

function val = find_named_depth(s, names, max_depth, depth)
    val = [];
    fn = fieldnames(s);
    for i = 1:numel(names)
        hit = fn(strcmpi(fn, names{i}));
        if ~isempty(hit)
            val = s.(hit{1});
            if ~isempty(val)
                return
            end
        end
    end
    if depth >= max_depth
        return
    end
    skip = {'duneuro_omitted_fields', 'duneuro_source_path'};
    for i = 1:numel(fn)
        if ismember(fn{i}, skip)
            continue
        end
        child = s.(fn{i});
        if isstruct(child) && isscalar(child)
            val = find_named_depth(child, names, max_depth, depth + 1);
            if ~isempty(val)
                return
            end
        end
    end
end
