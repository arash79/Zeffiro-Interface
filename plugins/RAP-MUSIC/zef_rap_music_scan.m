function [z_vec, loc_ind, orj_mat, A_top] = zef_rap_music_scan(L, L_ind, f, n_dipoles, S_mat)
%ZEF_RAP_MUSIC_SCAN  Mosher–Leahy RAP-MUSIC peel on a blocked lead field.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [z_vec, loc_ind, orj_mat, A_top] = zef_rap_music_scan(L, L_ind, f, n_dipoles, S_mat)
%
%   Recursively applied MUSIC (Mosher & Leahy, IEEE TBME 1999 / 1998 RAP
%   MUSIC): at peel k the already-found topographies A span a projector
%   P = I - QQ' (thin QR of A). The next location maximises the principal
%   subspace correlation of P L(r) against P Φ_s. Each found source is one
%   column a = L(r) u, not an elementwise L.*u' block.
%
%   L       - n_sensors × n_cols, plugin blocked layout from
%             zef_processLeadfields (x-block, y-block, z-block).
%   L_ind   - n_locations × n_ori; row n is the columns of location n
%             (3 for modes 1/2, 1 for mode 3).
%   f       - n_sensors × n_times (one RAP-MUSIC frame / window).
%   n_dipoles - requested peels; capped by the numerical rank of the
%             sample covariance.
%   S_mat   - sensor-space ridge: scalar, or n_sensors × n_sensors.
%
%   z_vec   - n_cols × 1; amplitude × orientation scattered into L_ind.
%   loc_ind - 1 × k found location rows of L_ind.
%   orj_mat - n_ori × k unit orientations.
%   A_top   - n_sensors × k oriented topographies.
%
%   See also zef_subspace_corr, RAP_MUSIC_iteration.

n_ch = size(L, 1);
n_ori = size(L_ind, 2);
n_loc = size(L_ind, 1);
if n_loc < 1 || n_ch < 1
    error('zef:RapMusic:EmptyLeadField', 'L / L_ind must be nonempty.');
end
if size(f, 1) ~= n_ch
    error('zef:RapMusic:SizeMismatch', ...
        'f has %d rows but L has %d sensors.', size(f, 1), n_ch);
end

f = double(gather(f));
L = double(gather(L));
n_dipoles = max(1, min(floor(double(n_dipoles)), n_loc));

if size(f, 2) > 1
    C = cov(f');
    f_amp = mean(f, 2);
else
    f0 = f - mean(f, 1);
    C = f0 * f0';
    f_amp = f;
end

[U_c, S_c] = svd(C, 'econ');
s_c = diag(S_c);
s_max = max([s_c; 0]);
if s_max <= 0
    error('zef:RapMusic:EmptySignalSubspace', ...
        'Sample covariance is zero; cannot form a signal subspace.');
end
k_sub = nnz(s_c > 1e-8 * s_max);
k_sub = min([n_dipoles, k_sub, size(U_c, 2)]);
if k_sub < 1
    error('zef:RapMusic:EmptySignalSubspace', ...
        'No nonzero covariance eigenvalues; lower inv_snr or use a longer window.');
end
Phi_s = U_c(:, 1:k_sub);
n_dipoles = min(n_dipoles, k_sub);

if isscalar(S_mat)
    ridge = double(S_mat) * eye(n_ch);
else
    ridge = double(gather(S_mat));
    if ~isequal(size(ridge), [n_ch, n_ch])
        ridge = ridge(1) * eye(n_ch);
    end
end

search_space = 1:n_loc;
loc_ind = zeros(1, n_dipoles);
orj_mat = zeros(n_ori, n_dipoles);
A_top = zeros(n_ch, 0);
P = [];

for d_iter = 1:n_dipoles
    s_max_corr = -inf;
    best_n = nan;
    best_u = [];
    for n = search_space
        L_n = L(:, L_ind(n, :));
        if isempty(A_top)
            [s, u] = zef_subspace_corr(L_n, Phi_s, 'max');
        else
            [s, u] = zef_subspace_corr(P * L_n, P * Phi_s, 'max');
        end
        u = u(1:size(L_n, 2));
        nu = norm(u);
        if nu == 0
            continue
        end
        u = u / nu;
        if s > s_max_corr
            s_max_corr = s;
            best_n = n;
            best_u = u;
        end
    end
    if isnan(best_n)
        loc_ind = loc_ind(1:d_iter-1);
        orj_mat = orj_mat(:, 1:d_iter-1);
        break
    end
    loc_ind(d_iter) = best_n;
    orj_mat(:, d_iter) = best_u;
    A = L(:, L_ind(best_n, :)) * best_u;
    na = norm(A);
    if na == 0
        loc_ind = loc_ind(1:d_iter-1);
        orj_mat = orj_mat(:, 1:d_iter-1);
        break
    end
    A_top = [A_top, A]; %#ok<AGROW>
    [Q, ~] = qr(A_top, 0);
    P = eye(n_ch) - Q * Q';
    search_space = setdiff(search_space, best_n);
end

k_found = size(A_top, 2);
z_vec = zeros(size(L, 2), 1);
if k_found < 1
    loc_ind = zeros(1, 0);
    orj_mat = zeros(n_ori, 0);
    return
end

lam = trace(ridge) / max(n_ch, 1);
z_amp = (A_top' * A_top + lam * eye(k_found)) \ (A_top' * f_amp);
for d_iter = 1:k_found
    cols = L_ind(loc_ind(d_iter), :);
    z_vec(cols) = z_amp(d_iter) * orj_mat(:, d_iter);
end

end
