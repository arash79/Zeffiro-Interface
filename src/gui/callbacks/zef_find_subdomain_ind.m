function [subdomain_ind] = zef_find_subdomain_ind(domain_labels, domain_labels_with_subdomains)
% --- Zeffiro documentation header ---
% zef_find_subdomain_ind — Zef find subdomain ind.
%
% Purpose:
%   Zef find subdomain ind.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   domain_labels
%   domain_labels_with_subdomains
%
% Outputs:
%   subdomain_ind
%
% Calls (project):
%   zef_find_subdomain_ind
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[subdomain_ind] = zef_find_subdomain_ind(domain_labels, domain_labels_with_subdomains)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
