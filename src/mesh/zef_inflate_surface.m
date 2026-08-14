function [nodes] = zef_inflate_surface(zef,nodes,surface_triangles,varargin)
%ZEF_INFLATE_SURFACE  Taubin λ/μ steps on a triangle mesh (source-surface inflate).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Same Laplacian as zef_smooth_surface, but λ = 1, μ = −1, scaled by
%   zef.inflate_strength, for zef.inflate_n_iterations steps (or the
%   optional 4th argument). Vertices not referenced by surface_triangles
%   get an identity row in the adjacency so they stay put. Used by
%   zef_downsample_surfaces to build <tag>_points_inf (sources slightly
%   inside tissue), and by segmentation import / SimNIBS / Brainstorm
%   converters. Not the same as zef_inflate_surfaces (FEM-node snap).
%
%   nodes = zef_inflate_surface(zef, nodes, surface_triangles)
%   nodes = zef_inflate_surface(zef, nodes, surface_triangles, n_iterations)
%
%   Inputs
%     zef                - session: inflate_n_iterations, inflate_strength,
%                          use_gpu, gpu_count. If GPU is on, A and nodes
%                          are gathered back to CPU at the end.
%     nodes              - N×3. Isolated vertices are unchanged.
%     surface_triangles  - F×3 1-based indices into nodes.
%     n_iterations       - optional override of inflate_n_iterations.
%
%   Output
%     nodes  - N×3, same rows as input (gather'ed if GPU was used).
%
%   See also zef_smooth_surface, zef_inflate_surfaces, zef_downsample_surfaces.

N = size(nodes,1);
if not(isempty(varargin))
smoothing_steps_surf = varargin{1};
else
smoothing_steps_surf = eval('zef.inflate_n_iterations');
end
smoothing_param = eval('zef.inflate_strength');

A = sparse(N, N, 0);
% Isolated vertices (not on the surface) get a 1 on the diagonal.
diag_ind_aux = unique(surface_triangles);
diag_aux = ones(N,1);
diag_aux(diag_ind_aux) = 0;

for i = 1 : 3
    for j = i+1 : 3
        A_part = sparse(surface_triangles(:,i),surface_triangles(:,j),double(ones(size(surface_triangles,1),1)),N,N);
        if i == j
            A = A + A_part;
        else
            A = A + A_part ;
            A = A + A_part';
        end
    end
end

clear A_part;
A = A + spdiags(diag_aux,0,N,N);
A = spones(A);
sum_A = full(sum(A))';
sum_A = sum_A(:,[1 1 1]);
% Taubin: expand (λ>0) then contract (μ<0) to limit shrinkage.
taubin_lambda = 1;
taubin_mu = -1;

if eval('zef.use_gpu') && eval('zef.gpu_count') > 0
    A = gpuArray(A);
    sum_A = gpuArray(sum_A);
    taubin_lambda = gpuArray(taubin_lambda);
    smoothing_param = gpuArray(smoothing_param);
    nodes = gpuArray(nodes);
end

for iter_ind_aux_1 = 1 : smoothing_steps_surf
    nodes_aux = A*nodes;
    nodes_aux = nodes_aux./sum_A;
    nodes_aux = nodes_aux - nodes;
    nodes =  nodes + taubin_lambda*smoothing_param*nodes_aux;
    nodes_aux = A*nodes;
    nodes_aux = nodes_aux./sum_A;
    nodes_aux = nodes_aux - nodes;
    nodes =  nodes + taubin_mu*smoothing_param*nodes_aux;

end

nodes = gather(nodes);

end
