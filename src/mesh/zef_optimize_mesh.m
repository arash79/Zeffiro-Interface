function [nodes, tetra] = zef_optimize_mesh(nodes,tetra)
%ZEF_OPTIMIZE_MESH  Unused wrapper: tetra_turn, restore mesh on failure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Calls zef_tetra_turn with zef.mesh_optimization_parameter from the
%   *base* workspace. The identifier zef is not an input; tetra_turn
%   therefore sees whatever zef is on the caller path (typically the
%   session in base when this is eval'd). On optimizer_flag == -1 the
%   original nodes/tetra are restored and errordlg is shown.
%
%   No first-party caller: postprocess calls zef_tetra_turn directly.
%
%   [nodes, tetra] = zef_optimize_mesh(nodes, tetra)
%
%   Inputs / outputs: V×3 nodes (unchanged by tetra_turn) and T×4 tetra.
%
%   See also zef_tetra_turn, zef_postprocess_fem_mesh.

nodes_old = nodes;
tetra_old = tetra;

[tetra, optimizer_flag] = zef_tetra_turn(zef, nodes, tetra, evalin('base','zef.mesh_optimization_parameter'));

if optimizer_flag == -1
    nodes = nodes_old;
    tetra = tetra_old;
    errordlg('Mesh optimization failed.');
    return;

end
