function pts_filename = save_atlas_points(mesh, out_folder)
%
% save_atlas_points - Write SimNIBS parcellation points from a mesh.
%
% Builds the point file directly from the SimNIBS Gmsh mesh tetrahedra. The
% tetra centroids provide the parcellation point coordinates. No coordinate
% transformation is applied here; callers should pass mesh.nodes in the frame
% that should be written.
%
% Inputs:
%
% - mesh (1,1) struct
%   Output of utilities.sn2zef.meshLoadGmsh4. Must expose nodes (N-by-3),
%   tetrahedra (M-by-4, 1-indexed), and tetrahedron_regions (M-by-1 labels).
%
% - out_folder (1,1) string { mustBeFolder }
%   Existing directory where sn_atlas_points.dat is written.
%
% Outputs:
%
% - pts_filename (1,1) string
%   Basename of the written point file.
%
% See also: utilities.sn2zef.run, utilities.sn2zef.meshLoadGmsh4
%

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
