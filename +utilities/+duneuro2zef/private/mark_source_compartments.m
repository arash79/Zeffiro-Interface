function payload = mark_source_compartments(payload)
%MARK_SOURCE_COMPARTMENTS  Tag brain-like and source-containing compartments.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if isempty(payload.compartment_tags)
        return
    end
    names = cell(1, numel(payload.compartment_tags));
    for i = 1:numel(payload.compartment_tags)
        tag = payload.compartment_tags{i};
        names{i} = lower(char(string(payload.([tag '_name']))));
        if any(contains(names{i}, {'brain', 'gray', 'grey', 'white', 'cortex', ...
                'hippocamp', 'thalam', 'cerebell'}))
            payload.([tag '_sources']) = 2;
        end
    end
    if ~isempty(payload.source_positions) && ~isempty(payload.nodes) && ~isempty(payload.tetra)
        centroids = (payload.nodes(payload.tetra(:, 1), :) ...
            + payload.nodes(payload.tetra(:, 2), :) ...
            + payload.nodes(payload.tetra(:, 3), :) ...
            + payload.nodes(payload.tetra(:, 4), :)) / 4;
        idx = nearest_rows(centroids, payload.source_positions);
        voted = unique(payload.domain_labels(idx));
        uniq = unique(payload.domain_labels);
        for i = 1:numel(uniq)
            if ismember(uniq(i), voted)
                tag = payload.compartment_tags{i};
                payload.([tag '_sources']) = 2;
            end
        end
        payload.brain_ind = find(ismember(payload.domain_labels, voted));
        payload.active_compartment_ind = payload.brain_ind;
    end
end

function idx = nearest_rows(database, query)
    try
        idx = knnsearch(database, query);
    catch
        idx = zeros(size(query, 1), 1);
        for i = 1:size(query, 1)
            delta = database - query(i, :);
            [~, idx(i)] = min(sum(delta.^2, 2));
        end
    end
end
