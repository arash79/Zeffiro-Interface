function node_ind = zef_point_in_cluster(reuna_p,reuna_t,nodes,threshold_value)
% --- Zeffiro documentation header ---
% zef_point_in_cluster — Zef point in cluster.
%
% Purpose:
%   Zef point in cluster.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   reuna_p
%   reuna_t
%   nodes
%   threshold_value
%
% Outputs:
%   node_ind
%
% Calls (project):
%   zef_point_in_cluster
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[node_ind] = zef_point_in_cluster(reuna_p, reuna_t, nodes, threshold_value)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
aux_vec_6 = sum(aux_vec_2./aux_vec_3)/(4*pi);
solid_angle_val = aux_vec_6(:);

node_ind = find(solid_angle_val> threshold_value );

end
