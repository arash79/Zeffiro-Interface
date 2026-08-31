function [condition_number, volume, longest_edge] = zef_condition_number(nodes, tetra)
%ZEF_CONDITION_NUMBER  Signed tet quality, volume, and longest edge.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Per-tetrahedron quality used by mesh optimization. Volume is the
%   signed scalar triple product of edges from vertex 4, divided by 6.
%   Zeffiro stores inverted (negative-volume) orientation as the valid
%   convention (zef_refinement_step swaps 1–2 when volume > 0).
%
%   Callers: zef_tetra_turn and zef_postprocess_fem_mesh (quality pass);
%   zef_fix_negatives (rows with condition_number < 0).
%
%   [condition_number, volume, longest_edge] = zef_condition_number(nodes, tetra)
%
%   Inputs
%     nodes  - V-by-3 coordinates.
%     tetra  - T-by-4 1-based vertex indices.
%
%   Outputs
%     condition_number - T-by-1; 1 for a regular tet in the stored
%                        (negative-volume) orientation, < 0 if inverted.
%     volume           - T-by-1 signed tet volumes.
%     longest_edge     - T-by-1 max of the six edge lengths.
%
%   See also zef_tetra_turn, zef_fix_negatives, zef_postprocess_fem_mesh.
ind_m = [1 4 7; 2 5 8 ; 3 6 9];
Aux_mat = [nodes(tetra(:,1),:)'; nodes(tetra(:,2),:)'; nodes(tetra(:,3),:)'] - repmat(nodes(tetra(:,4),:)',3,1);
volume = (Aux_mat(ind_m(1,1),:).*(Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,2),:)) ...
    - Aux_mat(ind_m(1,2),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,3),:)-Aux_mat(ind_m(2,3),:).*Aux_mat(ind_m(3,1),:)) ...
    + Aux_mat(ind_m(1,3),:).*(Aux_mat(ind_m(2,1),:).*Aux_mat(ind_m(3,2),:)-Aux_mat(ind_m(2,2),:).*Aux_mat(ind_m(3,1),:)))/6;

longest_edge = max(sqrt([sum((nodes(tetra(:,4),:) - nodes(tetra(:,1),:)).^2,2),...
    sum((nodes(tetra(:,4),:) - nodes(tetra(:,2),:)).^2,2),...
    sum((nodes(tetra(:,4),:) - nodes(tetra(:,3),:)).^2,2),...
    sum((nodes(tetra(:,3),:) - nodes(tetra(:,1),:)).^2,2),...
    sum((nodes(tetra(:,3),:) - nodes(tetra(:,2),:)).^2,2),...
    sum((nodes(tetra(:,2),:) - nodes(tetra(:,1),:)).^2,2)]),[],2);

% Regular tet: |V| = L^3 * sqrt(2)/12, so this is 1 when V is negative.
condition_number = - 12*volume(:)./(sqrt(2)*longest_edge.^3);

end
