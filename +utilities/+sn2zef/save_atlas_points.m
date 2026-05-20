function pts_filename = save_atlas_points(mesh, out_folder)
% --- Zeffiro documentation header ---
% utilities.sn2zef.save_atlas_points — Save atlas points.
%
% Purpose:
%   Save atlas points.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   mesh
%   out_folder
%
% Outputs:
%   pts_filename
%
% Calls (project):
%   utilities.sn2zef.save_atlas_points
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[pts_filename] = utilities.sn2zef.save_atlas_points(mesh, out_folder)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
