function volume_val = zef_find_enclosed_volume(nodes, triangles)
%ZEF_FIND_ENCLOSED_VOLUME  Scalar volume enclosed by a closed triangle mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. No first-party callers.
%
%   volume_val = zef_find_enclosed_volume(nodes, triangles)
%
%   Inputs
%     nodes      - N×3.
%     triangles  - F×3.
%
%   Output
%     volume_val  - abs((1/3) * sum(dot(centroid, n) * area)) with
%                   n = cross(p3-p1, p2-p1) and area = |n|/2.
%
%   See also zef_find_intersecting_triangle.

c_t = (1/3)*(nodes(triangles(:,1),:) + nodes(triangles(:,2),:) + nodes(triangles(:,3),:));
n_t = cross(nodes(triangles(:,3),:)'-nodes(triangles(:,1),:)', nodes(triangles(:,2),:)'-nodes(triangles(:,1),:)');
ala = sqrt(sum(n_t.^2))/2;
volume_val = abs((1/3)*sum(dot(c_t',n_t).*ala));

end
