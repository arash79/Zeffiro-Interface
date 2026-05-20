function tetra_ind = zef_get_tetra_to_refine(domain_ind, thresh_val, k_param, nodes, tetra, domain_labels, reuna_p,reuna_t)
% --- Zeffiro documentation header ---
% zef_get_tetra_to_refine — Zef get tetra to refine.
%
% Purpose:
%   Zef get tetra to refine.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   domain_ind
%   thresh_val
%   k_param
%   nodes
%   tetra
%   domain_labels
%   reuna_p
%   reuna_t
%
% Outputs:
%   tetra_ind
%
% Calls (project):
%   zef_get_tetra_to_refine
%   zef_surface_mesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[tetra_ind] = zef_get_tetra_to_refine(domain_ind, thresh_val, k_param, nodes, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header


tetra_ind = [];
I_aux = find(sum(ismember(domain_labels,domain_ind),2));
tetra = tetra(I_aux,:);
domain_labels = domain_labels(I_aux);

for i = 1 : length(domain_ind)

    u_t_ind = unique(reuna_t{domain_ind(i)});
    p_tri = reuna_p{domain_ind(i)}(u_t_ind,:);

    I = find(sum(ismember(domain_labels,domain_ind(i)),2));
    [domain_tri] = zef_surface_mesh(tetra,[],I);

    u_domain_tri_ind = unique(domain_tri);
    p_tetra = nodes(u_domain_tri_ind,:);

    MdlKDT = KDTreeSearcher(p_tetra);
    aux_ind = knnsearch(MdlKDT,p_tri);
    dist_vec = sqrt(sum((p_tetra(aux_ind,:) - p_tri).^2,2));
    dist_vec_ind = find(dist_vec > thresh_val*median(dist_vec));
    %dist_vec_ind = find(dist_vec > quantile(dist_vec,thresh_val));

    MdlKDT = KDTreeSearcher(p_tri);
    aux_ind = knnsearch(MdlKDT,p_tetra,'K',k_param);

    ref_ind = find(sum(ismember(aux_ind,dist_vec_ind),2));

    tetra_ind = [tetra_ind ; find(sum(ismember(tetra,u_domain_tri_ind(ref_ind)),2))];

end

tetra_ind = I_aux(tetra_ind);

end
