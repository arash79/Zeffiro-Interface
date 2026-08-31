function Minv = zef_sloreta3d_build_minv(P, L, src_inds)
%ZEF_SLORETA3D_BUILD_MINV  Per-source (P L)^{-1/2} for interleaved triplets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   For each source k in src_inds, G_k = P(I_k,:) L(:,I_k) with
%   I_k = {3k-2, 3k-1, 3k}, then Minv(:,:,k) = G_k^{-1/2} via pageeig.
%   Eigenvalues are floored at eps * max(1, |λ|) so a rank-deficient
%   triplet does not produce Inf/complex weights.
%
%   Minv = zef_sloreta3d_build_minv(P, L, src_inds)
%
%   See also zef_interleaved_source_columns, inverse.CSMInverter.

src_inds = src_inds(:);
ns = numel(src_inds);
if ns == 0
    Minv = zeros(3, 3, 0);
    return
end

[ix, iy, iz] = zef_interleaved_source_columns(src_inds);
G = zeros(3, 3, ns);
G(1, 1, :) = sum(P(ix, :) .* L(:, ix).', 2);
G(1, 2, :) = sum(P(ix, :) .* L(:, iy).', 2);
G(1, 3, :) = sum(P(ix, :) .* L(:, iz).', 2);
G(2, 1, :) = sum(P(iy, :) .* L(:, ix).', 2);
G(2, 2, :) = sum(P(iy, :) .* L(:, iy).', 2);
G(2, 3, :) = sum(P(iy, :) .* L(:, iz).', 2);
G(3, 1, :) = sum(P(iz, :) .* L(:, ix).', 2);
G(3, 2, :) = sum(P(iz, :) .* L(:, iy).', 2);
G(3, 3, :) = sum(P(iz, :) .* L(:, iz).', 2);
Gs = 0.5 * (G + pagetranspose(G));
[V, D] = pageeig(Gs);
evals = zeros(3, ns);
evals(1, :) = D(1, 1, :);
evals(2, :) = D(2, 2, :);
evals(3, :) = D(3, 3, :);
evals = real(evals);
eig_floor = eps * max(1, max(abs(evals), [], 1));
evals = max(evals, eig_floor);
Dinv = zeros(3, 3, ns);
Dinv(1, 1, :) = 1 ./ sqrt(evals(1, :));
Dinv(2, 2, :) = 1 ./ sqrt(evals(2, :));
Dinv(3, 3, :) = 1 ./ sqrt(evals(3, :));
Minv = pagemtimes(pagemtimes(V, Dinv), pagetranspose(V));
Minv = real(0.5 * (Minv + pagetranspose(Minv)));

end
