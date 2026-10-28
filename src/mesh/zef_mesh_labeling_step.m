function [tetra, nodes, domain_labels, distance_vec, label_ind] = zef_mesh_labeling_step(zef, tetra, nodes, label_ind, labeling_flag, domain_labels, distance_vec, h)
%ZEF_MESH_LABELING_STEP  Assign or refresh tetrahedron tissue IDs.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh arrays are arguments and return values. The function does not
%   read or write the caller workspace, and it does not assign zef.nodes.
%
%   [tetra, nodes, domain_labels, distance_vec, label_ind] = ...
%       zef_mesh_labeling_step(zef, tetra, nodes, label_ind, labeling_flag, ...
%           domain_labels, distance_vec, h)
%
%   Inputs
%     zef            - session (surfaces, priority_mode, smoothing flags).
%     tetra          - T×4 vertex indices.
%     nodes          - V×3 coordinates.
%     label_ind      - flag 1: T×8 cube-corner indices, or T×4 tet vertices
%                      when mesh_labeling_approach asks for that. Flags 2
%                      and 3: callers pass uint32(tetra).
%     labeling_flag  - 1 initial, 2 after refinement or smoothing, 3 final
%                      pass when priority_mode == 3.
%     domain_labels  - T×1 subdomain ids. Flag 1 overwrites this; pass [].
%     distance_vec   - V×1 nodal distances. Flag 1 overwrites this; pass [].
%     h              - waitbar handle passed through to the labeling helpers.
%
%   labeling_flag
%     1  Solid-angle labeling (zef_solid_angle_labeling). Drops tetrahedra
%        whose vertices are not all inside some compartment. Compacts
%        unused nodes. priority_mode 1 does not use labeling priority;
%        priority_mode 2 or 3 does. Optional distance smoothing.
%     2  zef_mesh_relabeling. priority_mode <= 2: no priority; == 3: use it.
%     3  Same relabel path as 2, always without labeling priority.
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

end
