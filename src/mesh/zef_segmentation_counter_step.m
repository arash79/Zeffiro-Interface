function ctx = zef_segmentation_counter_step(zef)
%ZEF_SEGMENTATION_COUNTER_STEP  Active-compartment index for the volume builder.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ctx = zef_segmentation_counter_step(zef)
%
%   Reads the session. Does not write the caller workspace.
%
%   ctx.mesh_res
%       zef.mesh_resolution.
%   ctx.reuna_type
%       zef.reuna_type.
%   ctx.pml_ind_aux
%       Index, among compartments with _on true, of the compartment whose
%       _sources is -1. Empty when there is no PML compartment. If several
%       are marked, the last one in compartment_tags is kept.
%   ctx.submesh_cell
%       zef.reuna_submesh_ind.
%   ctx.aux_active_compartment_ind
%       Indices, among _on compartments, whose _sources is 1 or 2.
%   ctx.name_tags
%       Names of _on compartments, in compartment_tags order.
%   ctx.submesh_ind_1, ctx.submesh_ind_2
%       Map each subdomain id to (reuna surface index, patch index). A
%       surface with an empty submesh list still occupies one slot.
%
%   Conductivity, labeling priority, and sigma vectors are not built here.
%   zef_choose_domain_labels and zef_postprocess_fem_mesh own those.
%
%   See also zef_create_fem_mesh, zef_process_meshes.

ctx = struct();
ctx.mesh_res = zef.mesh_resolution;
ctx.reuna_type = zef.reuna_type;
ctx.pml_ind_aux = [];
ctx.submesh_cell = zef.reuna_submesh_ind;
ctx.aux_active_compartment_ind = [];
ctx.name_tags = {};

active_count = 0;
for k = 1:length(zef.compartment_tags)
    tag = zef.compartment_tags{k};
    on_val = zef.([tag '_on']);
    if on_val
        active_count = active_count + 1;
        ctx.name_tags{active_count} = zef.([tag '_name']);
        sources = zef.([tag '_sources']);
        if isequal(sources, -1)
            ctx.pml_ind_aux = active_count;
        end
        if ismember(sources, [1 2])
            ctx.aux_active_compartment_ind = [ctx.aux_active_compartment_ind active_count];
        end
    end
end

n_subdomains = 0;
for k = 1:length(zef.reuna_p)
    n_subdomains = n_subdomains + max(1, length(ctx.submesh_cell{k}));
end

ctx.submesh_ind_1 = ones(n_subdomains, 1);
ctx.submesh_ind_2 = ones(n_subdomains, 1);
subdomain = 0;
for i = 1:length(zef.reuna_p)
    for k = 1:max(1, length(ctx.submesh_cell{i}))
        subdomain = subdomain + 1;
        ctx.submesh_ind_1(subdomain) = i;
        ctx.submesh_ind_2(subdomain) = k;
    end
end

end
