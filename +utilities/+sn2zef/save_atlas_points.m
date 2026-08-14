function pts_filename = save_atlas_points(mesh, out_folder)
%SAVE_ATLAS_POINTS  Tetra barycentres of labelled tets → sn_atlas_points.dat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   mesh.nodes, .tetrahedra, .tetrahedron_regions required. Non-zero region
%   tets only. Each row is [tet_index_0based, x, y, z] (mean of four
%   vertices), written with dlmwrite precision 6. Blocks of 250000 tets.
%   out_folder must exist. Used when a tetra mesh is already in memory.
%
%   pts_filename = save_atlas_points(mesh, out_folder)  % always sn_atlas_points.dat
%
%   See also save_volume_atlas_points.

    arguments
        mesh       (1,1) struct
        out_folder (1,1) string { mustBeFolder }
    end

    pts_filename = "sn_atlas_points.dat";
    pts_path = fullfile(out_folder, pts_filename);

    if ~isfield(mesh, 'tetrahedra') || isempty(mesh.tetrahedra)
        error('sn2zef:NoTetra', 'Mesh has no tetrahedra; cannot build atlas points.');
    end

    nodes        = double(mesh.nodes);
    tetra        = double(mesh.tetrahedra);
    tetra_labels = double(mesh.tetrahedron_regions(:));

    nz    = find(tetra_labels > 0);
    n_pts = numel(nz);
    if n_pts == 0
        error('sn2zef:NoAtlasPoints', 'Mesh tetrahedra contain no non-zero labels.');
    end

    centers = zeros(n_pts, 3);

    block_sz = 250000;
    for k0 = 1 : block_sz : n_pts
        blk = k0 : min(k0 + block_sz - 1, n_pts);
        ts  = tetra(nz(blk), :);
        centers(blk, :) = ( ...
              nodes(ts(:,1), :) ...
            + nodes(ts(:,2), :) ...
            + nodes(ts(:,3), :) ...
            + nodes(ts(:,4), :)) / 4;
    end

    pts_matrix = [nz - 1, centers];
    dlmwrite(pts_path, pts_matrix, 'delimiter', ' ', 'precision', 6);

end % function
