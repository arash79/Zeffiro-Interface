function barycentra = zef_tetra_barycentra(nodes, tetrahedra)
%ZEF_TETRA_BARYCENTRA  Arithmetic centroid of each tetrahedron.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For linear tetrahedral elements the centroid is also the barycentre
%   (equal vertex weights 1/4). Zeffiro uses these points as the default
%   evaluation location for a tetra: source placement (zef_decompose_dof_space
%   type 1 and 3), H(div)/Whitney/St. Venant interpolation positions, and
%   inside-tests during mesh labeling.
%
%   The result is in the same Cartesian frame and length unit as nodes
%   (typically millimetres in a head project). No unit conversion is applied.
%
%   barycentra = zef_tetra_barycentra(nodes, tetrahedra)
%
%   Inputs
%     nodes       - N-by-3 vertex coordinates.
%     tetrahedra  - T-by-4 1-based indices into nodes. Each row is one tet.
%
%   Output
%     barycentra  - T-by-3 centroids, row i matching tetrahedra(i,:).
%
%   See also zef_tetra_volume, zef_decompose_dof_space, zef_volume_gradient.

arguments
    nodes (:,3) double {mustBeNonNan}
    tetrahedra (:,4) double {mustBeInteger, mustBePositive}
end

% Equal-weight average of the four vertices; vectorized over all tetrahedra.
barycentra = 1 / 4 * ( ...
    nodes(tetrahedra(:,1),:) ...
    + ...
    nodes(tetrahedra(:,2),:) ...
    + ...
    nodes(tetrahedra(:,3),:) ...
    + ...
    nodes(tetrahedra(:,4),:) ...
    );
end
