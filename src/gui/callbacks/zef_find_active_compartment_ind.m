function [brain_ind, brain_compartments] = zef_find_active_compartment_ind(zef,domain_labels)
%ZEF_FIND_ACTIVE_COMPARTMENT_IND  Tetra indices whose domain is a source tissue.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Callers: zef_lead_field_matrix (zef.brain_ind),
%   zef_postprocess_fem_mesh, zef_refinement_step. Source tissues are
%   compartments with *_on and *_sources in {1,2}. Domain IDs packed into
%   domain_labels are 1..n_on in compartment_tags order (same packing as
%   zef_process_meshes reuna_*).
%
%   [brain_ind, brain_compartments] = zef_find_active_compartment_ind(zef)
%   [brain_ind, brain_compartments] = zef_find_active_compartment_ind(zef, domain_labels)
%
%   Inputs
%     zef            - session (compartment_tags, <tag>_on, <tag>_sources).
%     domain_labels  - N×1 tetra labels. Default zef.domain_labels.
%
%   Outputs
%     brain_ind          - tetra indices (column) in those source domains.
%                          If no compartment is on, find(domain_labels)
%                          (all non-zero labels).
%     brain_compartments - packed domain IDs (1..n_on) that are sources.
%
%   See also zef_find_subdomain_ind, zef_lead_field_matrix.

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
