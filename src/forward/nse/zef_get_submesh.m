function [nodes,simplexes,J] = zef_get_submesh(nodes,simplexes,I)
% --- Zeffiro documentation header ---
% zef_get_submesh — Zef get submesh.
%
% Purpose:
%   Zef get submesh.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   nodes
%   simplexes
%   I
%
% Outputs:
%   nodes
%   simplexes
%   J
%
% Calls (project):
%   zef_get_submesh
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[nodes, simplexes, J]] = zef_get_submesh(nodes, simplexes, I)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 3
simplexes = simplexes(I,:);
end

[J, ~, I_aux] = unique(simplexes);
simplexes(1:numel(simplexes)) = I_aux;
nodes = nodes(J,:);

end
