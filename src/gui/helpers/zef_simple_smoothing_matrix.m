function S_mat = zef_simple_smoothing_matrix(tetra, nodes)
% --- Zeffiro documentation header ---
% zef_simple_smoothing_matrix — Zef simple smoothing matrix.
%
% Purpose:
%   Zef simple smoothing matrix.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   tetra
%   nodes
%
% Outputs:
%   S_mat
%
% Calls (project):
%   zef_simple_smoothing_matrix
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[S_mat] = zef_simple_smoothing_matrix(tetra, nodes)` with project root and `src` on the path.
% --- End Zeffiro documentation header


n_nodes = size(nodes,1);
c_ave = 1/size(tetra,2);

S_mat = spalloc(n_nodes,n_nodes,0);

for i = 1 : size(tetra,2)
    for j = i : size(tetra,2) 

S_part = sparse(tetra(:,i),tetra(:,j),ones(size(tetra,1),1),n_nodes,n_nodes);

if i == j
    S_mat = S_mat + S_part;
else
    S_mat = S_mat + S_part;
    S_mat = S_mat + S_part';
end

    end
end

scale_vec=S_mat*ones(n_nodes,1);
D = spdiags(1./scale_vec,0,n_nodes,n_nodes);
S_mat = D*S_mat;

end
