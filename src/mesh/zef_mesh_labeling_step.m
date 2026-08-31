%ZEF_MESH_LABELING_STEP  Script: assign or refresh tet tissue IDs during meshing.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a function. zef_create_fem_mesh (and zef_smoothing_step when
%   mesh_relabeling is on) call it by name so it reads/writes the caller
%   workspace. Do not run it from the command line unless those variables
%   already exist.
%
%   Caller must provide
%     zef, nodes, tetra, h (waitbar)
%     labeling_flag  - 1 initial, 2 post-refinement, 3 priority_mode==3 final
%     label_ind      - for flag 1: T×8 cube-corner indices (or T×4 tet
%                      vertices, depending on mesh_labeling_approach).
%                      For flags 2/3 create_fem_mesh sets this to tetra.
%     domain_labels, distance_vec  - required for flags 2 and 3; flag 1
%                      overwrites both.
%
%   labeling_flag
%     1  Initial solid-angle labeling (zef_solid_angle_labeling). Drops
%        tets whose vertices are not all inside some compartment
%        (sum(sign(node_labels)) < n_vertices). Compacts unused nodes.
%        zef.priority_mode 1: no priority in zef_choose_domain_labels;
%        2 or 3: use labeling priority. Optional zef_distance_smoothing
%        of nodes when zef.distance_smoothing_on.
%     2  Relabel after refinement/smoothing. Calls zef_mesh_relabeling.
%        priority_mode ≤ 2: no priority; == 3: use priority.
%     3  Same relabel path as 2 but always without priority. create_fem_mesh
%        uses this at the end when priority_mode == 3.
%
%   Writes back: tetra, nodes, domain_labels, distance_vec, label_ind
%   (flag 1 only). Does not assign zef.nodes itself.
%
%   See also zef_create_fem_mesh, zef_mesh_relabeling, zef_solid_angle_labeling,
%            zef_choose_domain_labels.

label_ind = uint32(label_ind);

if isequal(labeling_flag,1)

    %***********************************************************
    %Initialize labeling.
    %***********************************************************

    [node_labels,distance_vec] = zef_solid_angle_labeling(zef, label_ind, nodes, h);

    % Keep tets whose every listed vertex has a positive compartment label.
    I = find(sum(sign(node_labels(label_ind)),2)>=size(label_ind,2));
    tetra = tetra(I,:);
    label_ind = label_ind(I,:);
    domain_labels = node_labels(label_ind);
 
    if zef.distance_smoothing_on
    [nodes] = zef_distance_smoothing(tetra, nodes, distance_vec, zef.distance_smoothing_exp, zef.smoothing_strength,zef.smoothing_steps_dist);
    end

    [unique_vec_1, ~, unique_vec_3] = unique(tetra);
    tetra = reshape(unique_vec_3,size(tetra));
    nodes = nodes(unique_vec_1,:);

        if zef.priority_mode == 1
            use_labeling_priority = 0;
        elseif zef.priority_mode >= 2
            use_labeling_priority = 1;
        end

    domain_labels = zef_choose_domain_labels(zef,domain_labels,use_labeling_priority);


elseif isequal(labeling_flag,2)
    %**************************************************************
    %Re-labeling.
    %**************************************************************

        if zef.priority_mode <= 2
            use_labeling_priority = 0;
        elseif zef.priority_mode == 3
            use_labeling_priority = 1;
        end

[domain_labels, distance_vec] = zef_mesh_relabeling(zef, tetra, nodes, domain_labels, distance_vec, use_labeling_priority, h);
 
if zef.distance_smoothing_on
    [nodes] = zef_distance_smoothing(tetra, nodes, distance_vec, zef.distance_smoothing_exp, zef.smoothing_strength, zef.smoothing_steps_dist);
end

elseif isequal(labeling_flag,3)
    %**************************************************************
    %Re-labeling.
    %**************************************************************

use_labeling_priority = 0;
[domain_labels, distance_vec] = zef_mesh_relabeling(zef, tetra, nodes, domain_labels, distance_vec, use_labeling_priority, h);
 
if zef.distance_smoothing_on
    [nodes] = zef_distance_smoothing(tetra, nodes, distance_vec, zef.distance_smoothing_exp, zef.smoothing_strength,zef.smoothing_steps_dist);
end

end
