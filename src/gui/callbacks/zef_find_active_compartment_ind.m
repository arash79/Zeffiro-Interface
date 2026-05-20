function [brain_ind, brain_compartments] = zef_find_active_compartment_ind(zef,domain_labels)
% --- Zeffiro documentation header ---
% zef_find_active_compartment_ind — Zef find active compartment ind.
%
% Purpose:
%   Zef find active compartment ind.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   domain_labels
%
% Outputs:
%   brain_ind
%   brain_compartments
%
% Zef fields (observed):
%   zef.compartment_tags (read)
%   zef.domain_labels (read)
%
% Calls (project):
%   zef_find_active_compartment_ind
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[brain_ind, brain_compartments]] = zef_find_active_compartment_ind(zef, domain_labels)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin < 2
    domain_labels = zef.domain_labels;
end

aux_compartment_ind = zeros(length(zef.compartment_tags),1);
i = 0;

for k = 1 : length(zef.compartment_tags)

    on_val = zef.([zef.compartment_tags{k} '_on']);

    if on_val
        i = i + 1;

        aux_compartment_ind(k) = i;

    end
end

brain_ind = [];
brain_compartments = [];
for k = 1 : length(zef.compartment_tags)
    if ismember(zef.([zef.compartment_tags{k} '_sources']),[1 2])
        if not(aux_compartment_ind(k)==0)
            brain_compartments(end+1) = aux_compartment_ind(k);
            [brain_ind]= [brain_ind ; find(domain_labels==aux_compartment_ind(k))];
        end
    end
end

if sum(aux_compartment_ind) == 0
    brain_ind = find(domain_labels);
end

end
