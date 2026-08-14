function [nodes,simplexes,J] = zef_get_submesh(nodes,simplexes,I)



%ZEF_GET_SUBMESH  Extract the nodal submesh of tetrahedra I (or all tetra).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   If nargin==3, simplexes = simplexes(I,:). Then unique node ids J are
%   extracted, simplexes are relabeled 1:numel(J), and nodes = nodes(J,:).
%   J maps new local node indices back to the parent mesh.
%
%   [nodes, simplexes, J] = zef_get_submesh(nodes, simplexes, I)
%
%   See also zef_nse_iteration, zef_nse_poisson.

if nargin == 3
simplexes = simplexes(I,:);
end

[J, ~, I_aux] = unique(simplexes);
simplexes(1:numel(simplexes)) = I_aux;
nodes = nodes(J,:);

end
