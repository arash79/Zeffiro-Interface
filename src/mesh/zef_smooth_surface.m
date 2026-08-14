function [smoothed_nodes] = zef_smooth_surface(nodes,triangles,smoothing_parameter,n_smoothing)
%ZEF_SMOOTH_SURFACE  Taubin λ=1 / μ=−1 Laplacian smooth of a triangle mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds the undirected adjacency of triangles, then for each iteration
%   moves every referenced vertex toward (then away from) the mean of its
%   neighbours: x ← x + λ s (Ax/deg − x), then the same with μ = −1.
%   Vertices not used by any triangle are left unchanged. Called from
%   zef_downsample_surfaces (s=1e-2, 1 step) and zef_import_segmentation_legacy.
%
%   smoothed_nodes = zef_smooth_surface(nodes, triangles, smoothing_parameter, n_smoothing)
%
%   Inputs
%     nodes               - N×3. Empty N → empty output.
%     triangles           - F×3 1-based indices.
%     smoothing_parameter - scalar s (typically 1e-2 in the downsample path).
%     n_smoothing         - number of λ/μ pairs.
%
%   Output
%     smoothed_nodes  - N×3, same size as nodes (or [] if N==0).
%
%   See also zef_inflate_surface, zef_downsample_surfaces.

smoothing_param = smoothing_parameter;
smoothing_steps_surf = n_smoothing;
N = size(nodes,1);

if N > 0

    A = sparse(N, N, 0);

    for i = 1 : 3
        for j = i+1 : 3
            A_part = sparse(triangles(:,i),triangles(:,j),double(ones(size(triangles,1),1)),N,N);
            if i == j
                A = A + A_part;
            else
                A = A + A_part ;
                A = A + A_part';
            end
        end
    end

    clear A_part;
    K = unique(triangles(:));
    A = spones(A);
    % Restrict the Laplacian to vertices that actually appear in triangles.
    sum_A = full(sum(A(K,K)))';

    sum_A = sum_A(:,[1 1 1]);
    taubin_lambda = 1;
    taubin_mu = -1;

    for iter_ind_aux_1 = 1 : smoothing_steps_surf
        nodes_aux = A(K,K)*nodes(K,:);
        nodes_aux = nodes_aux./sum_A;
        nodes_aux = nodes_aux - nodes(K,:);
        nodes(K,:) =  nodes(K,:) + taubin_lambda*smoothing_param*nodes_aux;
        nodes_aux = A(K,K)*nodes(K,:);
        nodes_aux = nodes_aux./sum_A;
        nodes_aux = nodes_aux - nodes(K,:);
        nodes(K,:) =  nodes(K,:) + taubin_mu*smoothing_param*nodes_aux;

    end

    smoothed_nodes = nodes;

else

    smoothed_nodes = [];

end

end
