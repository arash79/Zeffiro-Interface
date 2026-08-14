function node_ind = zef_point_in_cluster(reuna_p,reuna_t,nodes,threshold_value)
%ZEF_POINT_IN_CLUSTER  Solid-angle inside test for query points vs a triangle mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each query row of nodes, sums the signed solid angle of every
%   triangle in reuna_t / reuna_p and keeps indices where the sum / 4π
%   exceeds threshold_value. Same geometric idea as
%   zef_point_in_compartment, without GPU/waitbar/compartment wrapping.
%
%   Only first-party caller is zef_fix_negatives, which passes the tet
%   nodes as reuna_p, a local surface as reuna_t, and a candidate vertex
%   as nodes, with threshold zef.meshing_threshold. Empty node_ind means
%   the candidate is treated as outside.
%
%   node_ind = zef_point_in_cluster(reuna_p, reuna_t, nodes, threshold_value)
%
%   Inputs
%     reuna_p         - V-by-3 surface vertices.
%     reuna_t         - F-by-3 triangle indices into reuna_p.
%     nodes           - N-by-3 query points.
%     threshold_value - scalar solid-angle / 4π cutoff.
%
%   Output
%     node_ind - linear indices into nodes that pass the test.
%
%   See also zef_fix_negatives, zef_point_in_compartment.
aux_vec_1 = (1/3)*(reuna_p(reuna_t(:,1),:) + reuna_p(reuna_t(:,2),:) + reuna_p(reuna_t(:,3),:))';
aux_vec_2 = reuna_p(reuna_t(:,2),:)'-reuna_p(reuna_t(:,1),:)';
aux_vec_3 = reuna_p(reuna_t(:,3),:)'-reuna_p(reuna_t(:,1),:)';
aux_vec_4 = cross(aux_vec_2,aux_vec_3)/2;
ones_vec = ones(length(aux_vec_1),1);

aux_vec = reshape(nodes',3,1,size(nodes,1));
aux_vec_5 = aux_vec_1(:,:,ones(1,size(nodes,1))) - aux_vec(:,ones_vec,:);
aux_vec_2 = sum(aux_vec_5.*aux_vec_4(:,:,ones(1,size(nodes,1))));
aux_vec_3 = sqrt(sum(aux_vec_5.*aux_vec_5));
aux_vec_3 = (aux_vec_3.*aux_vec_3).*aux_vec_3;
% Projected area / r^3 summed over faces, then /4π → winding / solid angle.
aux_vec_6 = sum(aux_vec_2./aux_vec_3)/(4*pi);
solid_angle_val = aux_vec_6(:);

node_ind = find(solid_angle_val> threshold_value );

end
