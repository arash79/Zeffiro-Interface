function [I, distance_vec, label_vec] = zef_solid_angle_labeling(zef, tetra, nodes, h)
%ZEF_SOLID_ANGLE_LABELING  Assign each mesh node to a compartment by inside tests.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks zef.reuna_p / reuna_t (and submesh ranges in reuna_submesh_ind)
%   from the first surface to the last. For nodes not yet labeled, calls
%   zef_point_in_compartment (solid-angle sum vs zef.meshing_threshold).
%   The first surface that claims a node wins; remaining unlabeled nodes
%   get the last compartment index. That node labeling is what
%   zef_mesh_labeling_step uses to keep or drop tetrahedra.
%
%   The second argument is named tetra for historical reasons; this
%   function labels **nodes**, not tetra rows. Callers pass label_ind
%   (node indices of candidate tets) as that argument from
%   zef_mesh_labeling_step, which then uses the returned I as node_labels.
%
%   [I, distance_vec, label_vec] = zef_solid_angle_labeling(zef, tetra, nodes)
%   [I, distance_vec, label_vec] = zef_solid_angle_labeling(zef, tetra, nodes, h)
%
%   Inputs
%     zef           - session with reuna_p, reuna_t, reuna_submesh_ind,
%                     meshing_threshold, GPU flags.
%     tetra         - unused as connectivity here; kept for the caller
%                     signature (see above).
%     nodes         - N-by-3 candidate coordinates (typically all mesh nodes).
%     h             - optional waitbar handle. If omitted, this function
%                     creates and closes its own.
%
%   Outputs
%     I             - N-by-1 compartment counter (1 … n_submeshes).
%     distance_vec  - N-by-1 min distance to the winning surface (0 if none).
%     label_vec     - (n_submeshes)-by-1 [1:n] used to fill unlabeled nodes
%                     with the last index.
%
%   See also zef_point_in_compartment, zef_mesh_labeling_step.
if nargin < 4
h = zef_waitbar(0,'Mesh labeling.')
close_waitbar = true;
else
    close_waitbar = false;
end

I = zeros(size(nodes,1), 1);
distance_vec = zeros(size(nodes,1), 1);

    I_2 = [1 : length(I)]';

compartment_counter = 0;
submesh_vec = cell2mat(zef.reuna_submesh_ind);
n_compartments = length(submesh_vec);
label_vec = [1:n_compartments]';

for i_labeling =  1 : length(zef.reuna_p)
    for k_labeling =  1 : length(zef.reuna_submesh_ind{i_labeling})

compartment_counter = compartment_counter + 1;

if compartment_counter < n_compartments
     
            if isempty(zef.reuna_submesh_ind{i_labeling})
                reuna_t_aux = zef.reuna_t{i_labeling};
            else
                if k_labeling == 1
                    reuna_t_aux = zef.reuna_t{i_labeling}(1:zef.reuna_submesh_ind{i_labeling}(k_labeling),:);
                else
                    reuna_t_aux = zef.reuna_t{i_labeling}(zef.reuna_submesh_ind{i_labeling}(k_labeling-1)+1: zef.reuna_submesh_ind{i_labeling}(k_labeling),:);
                end
            end

                [I_1,distance_vec_aux] = zef_point_in_compartment(zef,zef.reuna_p{i_labeling},reuna_t_aux,nodes(I_2,:),[compartment_counter n_compartments]);
                I(I_2(I_1)) = compartment_counter;
                distance_vec(I_2(I_1)) = distance_vec_aux;

                I_2 = find(I==0);

end
    end
end

I_2 = find(I==0);
I(I_2) = label_vec(end);

if close_waitbar
close(h);
end
