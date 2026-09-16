function [ ...
    nearest_neighbour_inds, ...
    decomposition_count, ...
    dof_positions, ...
    decomposition_source_inds ...
    ] = zef_decompose_dof_space(nodes,tetrahedra,brain_ind,varargin)
%ZEF_DECOMPOSE_DOF_SPACE  Map brain tetrahedra to a reduced source / DOF set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds a source lattice from brain tetrahedra and, for each brain tetra,
%   the nearest lattice site. Type comes from varargin{3}, else
%   zef.dof_decomposition_type in the base workspace, else 2 (zef_init):
%     1  tetra barycentra of source_ind, KD-tree nearest neighbour
%     2  rectangular lattice sized from n_sources and the brain bounding box
%     3  identity: one DOF per brain tetra
%
%   Inputs
%     nodes        - N-by-3 mesh nodes (project length unit, typically mm).
%     tetrahedra   - T-by-4 node indices.
%     brain_ind    - linear indices of tetrahedra that may hold activity.
%     varargin{1}  - source tetra indices (default: brain_ind).
%     varargin{2}  - wanted source count n_sources (default: zef.n_sources
%                    in base, else 10000).
%     varargin{3}  - dof_decomposition_type (default: zef.dof_decomposition_type
%                    in base, else 2).
%
%   Outputs
%     nearest_neighbour_inds     - for each brain tetra, index into the
%                                  reduced DOF set (and into
%                                  decomposition_source_inds for types 1–2).
%     decomposition_count        - how many brain tetra map to each DOF
%                                  (for normalizing reconstructions).
%     dof_positions              - Cartesian coordinates of the reduced DOFs.
%     decomposition_source_inds  - indices into brain_ind usable as sources.
%
%   See also zef_tetra_barycentra, zef_lead_field_matrix.



if not(isempty(varargin))

    source_ind = varargin{1};

    if length(varargin) > 1
        n_sources = varargin{2};
    else
        n_sources = local_session_field('n_sources', 10000);
    end

    if length(varargin) > 2
        dof_decomposition_type = varargin{3};
    else
        dof_decomposition_type = local_session_field('dof_decomposition_type', 2);
    end

else

    source_ind = brain_ind;
    n_sources = local_session_field('n_sources', 10000);
    dof_decomposition_type = local_session_field('dof_decomposition_type', 2);

end

if isempty(source_ind)
    source_ind = brain_ind;
end

center_points = zef_tetra_barycentra(nodes, tetrahedra);
center_points = center_points(brain_ind,:);

if dof_decomposition_type == 1

    dof_positions = zef_tetra_barycentra(nodes, tetrahedra(source_ind, :));

    MdlKDT = KDTreeSearcher(dof_positions);
    nearest_neighbour_inds  = knnsearch(MdlKDT,center_points);

    [~, i_a, i_c] = unique(nearest_neighbour_inds);

    decomposition_count = accumarray(i_c,1);

    decomposition_source_inds = i_a;

elseif dof_decomposition_type == 2

    min_x = min(center_points(:,1));
    max_x = max(center_points(:,1));
    min_y = min(center_points(:,2));
    max_y = max(center_points(:,2));
    min_z = min(center_points(:,3));
    max_z = max(center_points(:,3));

    lattice_constant = n_sources.^(1/3)/((max_x - min_x)*(max_y - min_y)*(max_z - min_z))^(1/3);
    lattice_res_x = floor(lattice_constant*(max_x - min_x));
    lattice_res_y = floor(lattice_constant*(max_y - min_y));
    lattice_res_z = floor(lattice_constant*(max_z - min_z));

    l_d_x = (max_x - min_x)/(lattice_res_x + 1);
    l_d_y = (max_y - min_y)/(lattice_res_y + 1);
    l_d_z = (max_z - min_z)/(lattice_res_z + 1);

    min_x = min_x + l_d_x;
    max_x = max_x - l_d_x;
    min_y = min_y + l_d_y;
    max_y = max_y - l_d_y;
    min_z = min_z + l_d_z;
    max_z = max_z - l_d_z;

    x_space = linspace(min_x,max_x,lattice_res_x);
    y_space = linspace(min_y,max_y,lattice_res_y);
    z_space = linspace(min_z,max_z,lattice_res_z);

    [X_lattice, Y_lattice, Z_lattice] = meshgrid(x_space, y_space, z_space);

    dof_positions = [X_lattice(:) Y_lattice(:) Z_lattice(:)];

    nearest_neighbour_inds = lattice_index_fn( ...
        center_points, ...
        lattice_res_x, ...
        lattice_res_y, ...
        lattice_res_z ...
        );

    [unique_nearest_neighbour_ind, i_a, i_c] = unique(nearest_neighbour_inds);

    nearest_neighbour_ind_to_be = zeros(size(dof_positions,1),1);

    nearest_neighbour_ind_to_be(unique_nearest_neighbour_ind) = 1 : length(unique_nearest_neighbour_ind);

    nearest_neighbour_inds = nearest_neighbour_ind_to_be(nearest_neighbour_inds);

    dof_positions = dof_positions(unique_nearest_neighbour_ind,:);

    decomposition_count = accumarray(i_c,1);

    decomposition_source_inds = i_a;

elseif dof_decomposition_type == 3

    nearest_neighbour_inds = (1 : length(brain_ind))';

    decomposition_count = ones(size(nearest_neighbour_inds));

    dof_positions = center_points;

    decomposition_source_inds = (1 : length(brain_ind))';

else

    error('Unknown dof_decomposition_type');

end % if

end % zef_decompose_dof_space

%% Helper functions.

function out_indices = lattice_index_fn( ...
    in_center_points, ...
    in_lattice_res_x, ...
    in_lattice_res_y, ...
    in_lattice_res_z ...
    )

% Documentation
%
% A helper function for generating lattice indices based on the barycentra
% of the tetrahedra that form the lattice, and the x-, y- and z-resultions
% of the lattice.
%
% Input:
%
% - in_center_points: the barycenters of the tetrahedral lattice we are
%   observing.
%
% - in_lattice_res_x: the resolution of the lattice in the x-direction.
%
% - in_lattice_res_y: the resolution of the lattice in the y-direction.
%
% - in_lattice_res_z: the resolution of the lattice in the z-direction.
%
% Output:
%
% - out_indices
%
%   Linear index locations of the tetrehedral barycenters in the lattice
%   we are interested in.

arguments
    in_center_points (:,3) double
    in_lattice_res_x (1,1) double
    in_lattice_res_y (1,1) double
    in_lattice_res_z (1,1) double
end

% Aliases for shorter expressions.

cp1 = in_center_points(:,1);
cp2 = in_center_points(:,2);
cp3 = in_center_points(:,3);

lrx = in_lattice_res_x;
lry = in_lattice_res_y;
lrz = in_lattice_res_z;

% Absolute coordinates (relative coordinates times resolution) in the
% rectangular lattice.

acx = max(1, round( lrx * (cp1 - min(cp1)) ./ (max(cp1) - min(cp1))));
acy = max(1, round( lry * (cp2 - min(cp2)) ./ (max(cp2) - min(cp2))));
acz = max(1, round( lrz * (cp3 - min(cp3)) ./ (max(cp3) - min(cp3))));

% Linear indices from absolute coordinates.

out_indices = (acz-1) * lrx * lry + (acx-1) * lry + acy;

end

function val = local_session_field(name, default)
% Defaults match zef_init when the session is not in the base workspace.
try
    val = evalin('base', ['zef.' name]);
    if isempty(val)
        val = default;
    end
catch
    val = default;
end
end
