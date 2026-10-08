function result = zef_strip_burr_pick(local_nodes, tetra, domain_labels, domain_id, radius_mm, length_mm)
%ZEF_STRIP_BURR_PICK  Tetrahedra of one domain inside a finite lead cylinder.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   local_nodes are node coordinates in the lead frame (z along the shaft,
%   z = 0 at the tip, z = length_mm at the proximal end). A tetrahedron is
%   inside when its centroid, the average of its four vertices, has
%   radial distance <= radius_mm and axial coordinate on [0, length_mm].
%   The test is closed: a centroid on the boundary is included. The only
%   slack is 1e-8 mm, for floating-point roundoff, not for mesh size.
%   Disconnected pieces of the same domain are included only where they
%   meet the cylinder.
%
%   result = zef_strip_burr_pick(local_nodes, tetra, domain_labels, ...
%       domain_id, radius_mm, length_mm)
%
%   See also zef_strip_lead_frame, zef_strip_apply_burr_holes.

result.index = zeros(0, 1);
result.n_domain = 0;
result.max_radial_mm = NaN;
result.min_excluded_radial_mm = NaN;
result.axial_min_mm = NaN;
result.axial_max_mm = NaN;

if isempty(tetra) || isempty(domain_labels) || isempty(local_nodes)
    return
end
domain_labels = domain_labels(:);
if size(domain_labels, 1) ~= size(tetra, 1)
    error('zef:BurrHoleMesh', ...
        'domain_labels and tetra must have the same number of rows.');
end
mask = domain_labels == domain_id;
result.n_domain = nnz(mask);
if result.n_domain == 0
    return
end
sel = find(mask);
tet = tetra(sel, :);
if any(tet(:) < 1) || any(tet(:) > size(local_nodes, 1))
    error('zef:BurrHoleMesh', ...
        'Tetrahedron indices exceed the node array.');
end
centroid = (local_nodes(tet(:, 1), :) + local_nodes(tet(:, 2), :) ...
    + local_nodes(tet(:, 3), :) + local_nodes(tet(:, 4), :)) * 0.25;
radial = hypot(centroid(:, 1), centroid(:, 2));
axial = centroid(:, 3);
tol = 1e-8;
in_axis = axial >= -tol & axial <= (length_mm + tol);
inside = in_axis & radial <= (radius_mm + tol);
result.index = sel(inside);
if any(inside)
    result.max_radial_mm = max(radial(inside));
    result.axial_min_mm = min(axial(inside));
    result.axial_max_mm = max(axial(inside));
end
outside_span = in_axis & ~inside;
if any(outside_span)
    result.min_excluded_radial_mm = min(radial(outside_span));
end

end
