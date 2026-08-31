%ZEF_SEGMENTATION_COUNTER_STEP  Script: inject compartment lists into create_fem_mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a function. zef_create_fem_mesh calls it first so the volume builder
%   can see mesh_res, reuna_type, pml_ind_aux, submesh_cell, name_tags,
%   aux_active_compartment_ind, and the labeling-priority vectors without
%   passing them as extra arguments. zef_smoothing_step also calls it on
%   the first smoothing repetition when mesh_relabeling is on.
%
%   Reads from zef (caller workspace)
%     compartment_tags, mesh_resolution, reuna_type, reuna_p, reuna_submesh_ind,
%     sensors, and per-tag _on / _sigma / _priority / _name / _sources /
%     optional _labeling_priority.
%
%   Writes into the caller workspace (not onto zef)
%     mesh_res              - copy of zef.mesh_resolution
%     reuna_type, sensors   - copies
%     pml_ind, pml_ind_aux  - index among *active* compartments of the one
%                             with _sources == -1 (PML), or []
%     sigma_vec, priority_vec - one row per active (_on) compartment
%     labeling_priority_aux_1 - per active compartment (0 if field missing)
%     name_tags             - 1×C cell of names
%     aux_active_compartment_ind - active compartments with _sources in {1,2}
%     submesh_cell          - zef.reuna_submesh_ind
%     n_compartments        - sum over surfaces of max(1, n_submeshes)
%     submesh_ind_1, submesh_ind_2 - map subdomain id → (reuna index, patch k)
%     priority_vec_labeling - length n_compartments: copy of the parent
%                             compartment priority, then overwritten on
%                             entries where labeling_priority_aux_2 is
%                             nonzero; others are shifted by
%                             max(labeling_priority_aux_2)
%
%   See also zef_create_fem_mesh, zef_process_meshes, zef_smoothing_step.
pml_ind_aux = [];
pml_ind = [];

mesh_res = eval('zef.mesh_resolution');
reuna_type = eval('zef.reuna_type');
sensors = eval('zef.sensors');

i = 0;
sigma_vec = [];
priority_vec = [];
labeling_priority_aux_1 = [];
submesh_cell = zef.reuna_submesh_ind;
aux_active_compartment_ind = [];
compartment_tags = eval('zef.compartment_tags');

for k = 1 : length(compartment_tags)

    var_0 = ['zef.' compartment_tags{k} '_on'];
    var_1 = ['zef.' compartment_tags{k} '_sigma'];
    var_2 = ['zef.' compartment_tags{k} '_priority'];
    var_3 = ['zef.' compartment_tags{k} '_submesh_ind'];
    var_4 = ['zef.' compartment_tags{k} '_name'];
    var_5 = ['zef.' compartment_tags{k} '_sources'];

    labeling_priority_val = 0;
    if isfield(zef,[compartment_tags{k} '_labeling_priority'])
      labeling_priority_val = zef.([compartment_tags{k} '_labeling_priority']);
    end

    on_val = eval(var_0);
    sigma_val = eval(var_1);
    priority_val = eval(var_2);

    if on_val
        i = i + 1;

        sigma_vec(i,1) = sigma_val;
        priority_vec(i,1) = priority_val;
        labeling_priority_aux_1(i,1) = labeling_priority_val;
        name_tags{i} = eval(var_4);

        if isequal(eval(var_5),-1)
            % This active compartment is the PML box (_sources == -1).
            pml_ind_aux = i;
        end

        if ismember(eval(var_5),[1 2])
            aux_active_compartment_ind = [aux_active_compartment_ind i];
        end

    end
end

n_compartments = 0;
for k = 1 : length(zef.reuna_p)
    n_compartments = n_compartments + max(1,length(submesh_cell{k}));
end

priority_vec_labeling = zeros(n_compartments,1);
labeling_priority_aux_2 = zeros(n_compartments,1);
compartment_counter = 0;
submesh_ind_1 = ones(n_compartments,1);
submesh_ind_2 = ones(n_compartments,1);

for i = 1 :  length(zef.reuna_p)

    for k = 1 : max(1,length(submesh_cell{i}))

        compartment_counter = compartment_counter + 1;
        priority_vec_labeling(compartment_counter) = priority_vec(i);
        labeling_priority_aux_2(compartment_counter) = labeling_priority_aux_1(i);
        submesh_ind_1(compartment_counter) = i;
        submesh_ind_2(compartment_counter) = k;

    end
end


priority_vec_labeling = priority_vec_labeling + max(labeling_priority_aux_2);
% Explicit per-compartment labeling_priority replaces the shifted default.
priority_vec_labeling(find(labeling_priority_aux_2)) = labeling_priority_aux_2(find(labeling_priority_aux_2));
