function [subdomain_ind] = zef_find_subdomain_ind(domain_labels, domain_labels_with_subdomains)
%ZEF_FIND_SUBDOMAIN_IND  Local 1..K subdomain index within each domain label.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Caller: zef_postprocess_fem_mesh (after labeling,
%   to split a tissue into submeshes). Pure array helper; no zef, no GUI.
%
%   subdomain_ind = zef_find_subdomain_ind(domain_labels, domain_labels_with_subdomains)
%
%   Inputs
%     domain_labels                 - N×1 coarse domain ID per tetra.
%     domain_labels_with_subdomains - N×1 finer labels (submesh IDs).
%
%   Output
%     subdomain_ind  - N×1. For each unique domain_labels value, the
%                      matching finer labels are uniqued and rewritten as
%                      1..K in uniqueness order.
%
%   See also zef_find_active_compartment_ind, zef_postprocess_fem_mesh.

unique_domain_labels = unique(domain_labels);
subdomain_ind = zeros(length(domain_labels),1);

for i = 1 : length(unique_domain_labels)

I_1 = find(domain_labels==unique_domain_labels(i));
subdomain_aux = domain_labels_with_subdomains(I_1);
[I_2,~,I_3] = unique(subdomain_aux);
I_4 = [1:length(I_2)];
subdomain_aux = I_4(I_3);
subdomain_ind(I_1) = subdomain_aux;

end

end
