function [condition_number, volume, longest_edge] = zef_condition_number(nodes, tetra)
% --- Zeffiro documentation header ---
% zef_condition_number — Zef condition number.
%
% Purpose:
%   Zef condition number.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   nodes
%   tetra
%
% Outputs:
%   condition_number
%   volume
%   longest_edge
%
% Calls (project):
%   zef_condition_number
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[condition_number, volume, longest_edge]] = zef_condition_number(nodes, tetra)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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

condition_number = - 12*volume(:)./(sqrt(2)*longest_edge.^3);

end
