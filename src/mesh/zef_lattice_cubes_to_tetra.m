function [tetra, label_ind] = zef_lattice_cubes_to_tetra(X, initial_mesh_mode, mesh_labeling_approach)
%ZEF_LATTICE_CUBES_TO_TETRA  Split a Cartesian lattice into tetrahedra.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [tetra, label_ind] = zef_lattice_cubes_to_tetra(X, mode, labeling)
%
%   Cube order is i_x (slowest), i_y, i_z (fastest), matching the
%   historical nested loops in zef_create_fem_mesh. Corner numbering is
%   1–4 bottom, 5–8 top. Mode 1 uses parity-dependent 5-tet stencils so
%   neighbouring cubes share a face diagonal. Mode 2 uses one 6-tet
%   stencil. labeling 1 stores the eight cube corners on every tet;
%   labeling 2 stores the tet vertices.
%
%   See also zef_create_fem_mesh.

size_xyz = size(X);
n_x = size_xyz(2) - 1;
n_y = size_xyz(1) - 1;
n_z = size_xyz(3) - 1;
n_cubes = n_x * n_y * n_z;
[i_z, i_y, i_x] = ndgrid(1:n_z, 1:n_y, 1:n_x);
ix = i_x(:);
iy = i_y(:);
iz = i_z(:);
cx = [0 1 1 0 0 1 1 0];
cy = [0 0 1 1 0 0 1 1];
cz = [0 0 0 0 1 1 1 1];
ind_mat_2 = sub2ind(size_xyz, iy + cy, ix + cx, iz + cz);

if isequal(initial_mesh_mode, 1)
    ind_mat_1{1}{2}{1} = [2 5 6 7; 7 5 4 2;  2 3 4 7; 1 2 4 5 ; 4 7 8 5];
    ind_mat_1{1}{2}{2} = [6 2 1 3; 1 3 8 6; 8 7 6 3;  5 8 6 1; 3 8 4 1 ];
    ind_mat_1{2}{2}{2} = [5 2 1 4; 4 2 7 5; 5 8 7 4;  5 7 6 2;  3 7 4 2];
    ind_mat_1{2}{2}{1} = [1 5 6 8; 6 8 3 1; 3 4 1 8; 2 3 1 6 ; 3 7 8 6  ];
    ind_mat_1{1}{1}{2} = [4 3 7 2; 2 7 4 5;  5 7 6 2; 1 5 2 4;  8 7 5 4 ];
    ind_mat_1{2}{1}{2} = [3 6 8 1; 1 3 4 8; 5 8 6 1; 1 6 2 3  ; 8 7 6 3  ];
    ind_mat_1{1}{1}{1} = [7 8 3 6; 8 1 3 6; 2 3 1 6;  1 5 6 8 ; 1 3 4 8   ];
    ind_mat_1{2}{1}{1} = [ 7 8 4 5; 5 4 7 2;  2 4 1 5; 2 5 6 7   ;  2 3 4 7 ];

    S = zeros(5, 4, 2, 2, 2);
    for px = 1:2
        for py = 1:2
            for pz = 1:2
                S(:,:,px,py,pz) = ind_mat_1{px}{py}{pz};
            end
        end
    end
    px = 2 - mod(ix, 2);
    py = 2 - mod(iy, 2);
    pz = 2 - mod(iz, 2);
    lin_s = sub2ind([2 2 2], px, py, pz);
    Sflat = reshape(S, 5, 4, 8);
    col_idx = reshape(permute(Sflat(:,:,lin_s), [2 1 3]), 20, n_cubes)';
    gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
    tetra = reshape(gathered', 4, [])';
    n_tets = 5;
elseif isequal(initial_mesh_mode, 2)
    ind_mat_1 = [     3     4     1     7 ;
        2     3     1     7 ;
        1     2     7     6 ;
        7     1     6     5 ;
        7     4     1     8 ;
        7     8     1     5  ];
    col_idx = repmat(reshape(ind_mat_1', 1, 24), n_cubes, 1);
    gathered = ind_mat_2((1:n_cubes)' + (col_idx - 1) * n_cubes);
    tetra = reshape(gathered', 4, [])';
    n_tets = 6;
else
    error('zef_lattice_cubes_to_tetra:UnknownMode', ...
        'initial_mesh_mode must be 1 (5 tets) or 2 (6 tets).');
end

if isequal(mesh_labeling_approach, 1)
    label_ind = repelem(ind_mat_2, n_tets, 1);
elseif isequal(mesh_labeling_approach, 2)
    label_ind = tetra;
else
    label_ind = [];
end

end
