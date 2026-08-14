

function [boundary_vec_1, boundary_vec_2] = boundary_point_source(source_points, orbit_triangles, orbit_nodes)
%BOUNDARY_POINT_SOURCE  Near-field point sources snapped onto orbit triangles.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Used when near_field==1 in compute_data_gpu. Two polarizations, no fade.
%
%   [boundary_vec_1, boundary_vec_2] = boundary_point_source( ...
%       source_points, orbit_triangles, orbit_nodes)
%
%   See also boundary_source.




n_triangles = size(orbit_triangles(:,1), 1);
n_nodes = size(orbit_nodes(:,1), 1);
n_source_points = size(source_points,1);

boundary_vec_1 = zeros(n_nodes,n_source_points);
boundary_vec_2 = zeros(n_nodes,n_source_points);

for i = 1 : n_source_points
    [d_min, d_ind] = min(sum((repmat(source_points(i,:),n_nodes,1) - orbit_nodes).^2,2));
    boundary_vec_2(d_ind,i) = 1;
end
