function aux_compartment_ind = zef_dti_active_compartment_map(zef)
%ZEF_DTI_ACTIVE_COMPARTMENT_MAP  Tag index → domain_labels value.
%
%   Zeffiro Interface.
%   Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   domain_labels stores indices of ACTIVE compartments (those with
%   <tag>_on true), not raw compartment_tags positions. This is the same
%   numbering zef_find_active_compartment_ind uses.
%
%   aux_compartment_ind = zef_dti_active_compartment_map(zef)
%
%   Output
%     aux_compartment_ind - n_tags×1. Entry k is the domain_labels value
%                           for compartment_tags{k}, or 0 if that compartment
%                           is off or has no <tag>_on field.
%
%   See also zef_dti_apply_to_sigma, zef_find_active_compartment_ind.

arguments
    zef (1,1) struct
end

if ~isfield(zef, "compartment_tags") || isempty(zef.compartment_tags)
    aux_compartment_ind = zeros(0, 1);
    return
end

n = numel(zef.compartment_tags);
aux_compartment_ind = zeros(n, 1);
active = 0;
for k = 1:n
    tag_name = zef.compartment_tags{k};
    on_field = [tag_name '_on'];
    if isfield(zef, on_field) && zef.(on_field)
        active = active + 1;
        aux_compartment_ind(k) = active;
    end
end

end
