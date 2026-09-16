function [payload, report] = fill_compartments(payload, raw, original_ids, report)
%FILL_COMPARTMENTS  Default compartment fields from DUNEuro tissue IDs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    labels = unique(payload.domain_labels);
    labels = labels(:)';
    name_ids = original_ids;
    if numel(name_ids) ~= numel(labels)
        name_ids = labels;
    end
    names = tissue_names(raw, name_ids);
    conductivity = find_conductivity(raw);
    payload.compartment_tags = cell(1, numel(labels));
    for i = 1:numel(labels)
        tag = sprintf('c%d', i);
        payload.compartment_tags{i} = tag;
        lab = labels(i);
        payload.([tag '_on']) = 1;
        payload.([tag '_visible']) = 1;
        payload.([tag '_sources']) = 0;
        payload.([tag '_priority']) = i;
        payload.([tag '_name']) = names{i};
        orig_lab = lab;
        if numel(name_ids) >= i
            orig_lab = name_ids(i);
        end
        payload.([tag '_sigma']) = sigma_for_label(conductivity, orig_lab, name_ids, i);
        tet_ind = find(payload.domain_labels == lab);
        try
            [tri, pts] = zef_surface_mesh(payload.tetra, payload.nodes, tet_ind);
            payload.([tag '_points']) = pts;
            payload.([tag '_triangles']) = tri;
        catch
            payload.([tag '_points']) = [];
            payload.([tag '_triangles']) = [];
            report.warnings{end+1} = sprintf( ...
                'Could not extract a surface for compartment %s (label %g).', tag, lab);
        end
    end
end

function names = tissue_names(raw, labels)
    names = arrayfun(@(k) sprintf('DUNEuro tissue %g', k), labels, 'UniformOutput', false);
    val = find_named(raw, {'tissuelabel', 'tissue_labels', 'tissue_names', ...
        'cond_names', 'compartment_names'}, 2);
    if isstring(val) || ischar(val)
        val = cellstr(val);
    end
    if iscell(val) && numel(val) == numel(labels)
        names = val(:)';
    elseif iscell(val) && numel(val) >= max(labels) && min(labels) >= 1
        names = val(labels);
        names = names(:)';
    end
end
