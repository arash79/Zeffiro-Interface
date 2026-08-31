function [z, reconstruction_information] = zef_dipoleScan(zef)
%ZEF_DIPOLESCAN  Dipole scan (single-dipole fit) inverse plugin.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [z, reconstruction_information] = zef_dipoleScan(zef)
%
%   Called from Dipole Scan StartButton (not inverse.DipoleScanInverter).
%   Needs zef.L and zef.measurements. Frames: zef.number_of_frames,
%   zef_getFilteredData / zef_getTimeStep. Method/regularization from
%   zef.dipole_app.InversionmethodDropDown / regType / inv_leadfield_lambda
%   (SVD or pinv). SNR stored in reconstruction_information (zef.inv_snr).
%   Returns cell z (one vector per frame) and info (full GOF map).
%
%   Lead-field SVDs are precomputed once; each frame only applies them to f.
%
%   See also zef_dipole_start, zef_dipole_window.
%

invMethod=eval( 'zef.dipole_app.InversionmethodDropDown.Value');
regType=eval( 'zef.dipole_app.regType.Value');
inv_leadfield_lambda=eval( 'zef.dipole_app.inv_leadfield_lambda.Value');

reconstruction_information.tag =strcat('Dipole', invMethod);
reconstruction_information.type = 'Dipole';
reconstruction_information.invMethod=invMethod;
reconstruction_information.regType=regType;
reconstruction_information.inv_leadfield_lambda=inv_leadfield_lambda;
reconstruction_information.inv_time_1 = eval('zef.inv_time_1');
reconstruction_information.inv_time_2 = eval('zef.inv_time_2');
reconstruction_information.inv_time_3 = eval('zef.inv_time_3');
reconstruction_information.sampling_freq = eval('zef.inv_sampling_frequency');
reconstruction_information.low_pass = eval('zef.inv_high_cut_frequency');
reconstruction_information.high_pass = eval('zef.inv_low_cut_frequency');
reconstruction_information.source_direction_mode = eval('zef.source_direction_mode');
reconstruction_information.source_directions = eval('zef.source_directions');
reconstruction_information.inv_hyperprior = eval('zef.inv_hyperprior');
reconstruction_information.snr_val = eval('zef.inv_snr');
reconstruction_information.number_of_frames = eval('zef.number_of_frames');

h = zef_waitbar(0,1,'Dipole scanning');

number_of_frames = eval('zef.number_of_frames');
source_direction_mode = eval('zef.source_direction_mode');

[L,n_interp, procFile] = zef_processLeadfields(zef);

if ~ismember(source_direction_mode, [1, 2])
    close(h);
    error('zef:DipoleScan:UnsupportedDirectionMode', ...
        ['Plugin dipole scan supports source_direction_mode 1 and 2 ' ...
        '(blocked Cartesian triples after zef_processLeadfields). Mode %g is not implemented.'], ...
        source_direction_mode);
end

z = cell(number_of_frames,1);
f_data = zef_getFilteredData(zef);

scan = [];
if ismember(source_direction_mode, [1, 2])
    scan.normal = procFile.s_ind_4;
    scan.notNormal = setdiff(1:length(procFile.s_ind_0), procFile.s_ind_4);
    scan.n_interp = n_interp;
    scan.rank_reduce = strcmp('SVD', regType);
    scan.k = str2double(inv_leadfield_lambda);
    scan.invMethod = invMethod;
    scan = i_precompute_scan(scan, L);
end

tic;
for f_ind = 1 : number_of_frames

    time_val = toc;
    if f_ind > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400));
        zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);

    end

    f=zef_getTimeStep(f_data, f_ind, zef);

    z_vec = nan(size(L,2),1);

    %% inversion starts here

    z_vec = i_apply_scan(z_vec, f, scan);

    [z_max]=max(z_vec);
    reconstruction_information.maximum=z_max;

    z{f_ind}=z_vec;

    %%

end

z = zef_postProcessInverse(z, procFile);
z = zef_normalizeInverseReconstruction(z);

close(h);
end

function scan = i_precompute_scan(scan, L)
%I_PRECOMPUTE_SCAN
% Precompute all time-invariant dipole-scan factorizations.
%
% Preserves the distinction between:
%   invMethod = 'SVD'
%   invMethod = 'pinv'
%
% while avoiding recomputing an SVD for every source and every frame.

n_ch = size(L, 1);
n_interp = scan.n_interp;

normal = scan.normal(:);
notNormal = scan.notNormal(:);
n_free = numel(notNormal);

%% Fixed-orientation sources

if isempty(normal)
    scan.L_fixed = [];
    scan.L_fixed_norm2 = [];
    scan.L_fixed_valid = [];
else
    scan.L_fixed = L(:, normal);
    scan.L_fixed_norm2 = sum(abs(scan.L_fixed).^2, 1).';

    % For a single-column matrix, pinv returns zero only when the
    % singular value is below MATLAB's default tolerance.
    if strcmp(scan.invMethod, 'pinv')

        s_fixed = sqrt(scan.L_fixed_norm2);

        % pinv tolerance:
        % tol = max(size(A)) * eps(norm(A))
        tol_fixed = n_ch .* eps(s_fixed);

        scan.L_fixed_valid = s_fixed > tol_fixed;

    else

        scan.L_fixed_valid = true(size(scan.L_fixed_norm2));

    end
end

%% Initialise free-orientation quantities

scan.U = [];
scan.S = [];
scan.V = [];
scan.V_reg = [];
scan.active_singular = [];

if n_free == 0
    return
end

%% Construct all 3-D lead fields as pages

L_pages = zeros( ...
    n_ch, ...
    3, ...
    n_free, ...
    'like', L);

L_pages(:, 1, :) = L(:, notNormal);
L_pages(:, 2, :) = L(:, notNormal + n_interp);
L_pages(:, 3, :) = L(:, notNormal + 2*n_interp);

%% Optional dimensionality reduction

if scan.rank_reduce && ...
        isfinite(scan.k) && ...
        scan.k >= 1 && ...
        scan.k <= 3

    k = floor(scan.k);

    % Equivalent to:
    %
    %   [~,~,V_reg] = svd(lf,'econ');
    %   lf = lf * V_reg(:,1:k);
    %
    % for every source.

    [~, ~, V_all] = pagesvd(L_pages, "econ");

    scan.V_reg = V_all(:, 1:k, :);

    L_work = pagemtimes(L_pages, scan.V_reg);

else

    scan.rank_reduce = false;
    scan.V_reg = [];

    k = 3;
    L_work = L_pages;

end

%% SVD of each effective lead field

[U, S_vec, V] = pagesvd( ...
    L_work, ...
    "econ", ...
    "vector");

scan.U = U;
scan.S = reshape(S_vec, k, n_free);
scan.V = V;

%% Singular-value policy

if strcmp(scan.invMethod, 'pinv')

    % MATLAB pinv(A) uses approximately:
    %
    %   tol = max(size(A)) * eps(norm(A))
    %
    % Since norm(A) is the largest singular value:
    %
    %   norm(A) = S(1)
    %
    % Compute the tolerance independently for every dipole.

    largest_singular = scan.S(1, :);

    tol = max(n_ch, k) .* eps(largest_singular);

    scan.active_singular = ...
        scan.S > tol;

else

    % Original SVD path does not intentionally truncate small
    % singular values.
    %
    % Exact zero singular values are excluded here only to prevent
    % division by zero in the vectorized implementation.

    scan.active_singular = ...
        scan.S ~= 0;

end

end

function z_vec = i_apply_scan(z_vec, f, scan)
%I_APPLY_SCAN
% Apply the precomputed dipole-scan factors to one data frame.

fn2 = sum(abs(f).^2);

if fn2 <= 0
    return
end

n_interp = scan.n_interp;

normal = scan.normal(:);
notNormal = scan.notNormal(:);

%% ---------------------------------------------------------------
% Fixed-orientation sources
% ---------------------------------------------------------------

if ~isempty(normal) && ~isempty(scan.L_fixed)

    Lfix = scan.L_fixed;

    coln2 = scan.L_fixed_norm2;

    proj = Lfix' * f;

    gof_fixed = zeros( ...
        size(coln2), ...
        'like', proj);

    valid = scan.L_fixed_valid & (coln2 > 0);

    gof_fixed(valid) = ...
        abs(proj(valid)).^2 ./ ...
        (coln2(valid) .* fn2);

    z_vec(normal) = gof_fixed;

    z_vec(normal + n_interp) = gof_fixed;

    z_vec(normal + 2*n_interp) = gof_fixed;

end

%% ---------------------------------------------------------------
% Free-orientation sources
% ---------------------------------------------------------------

n_free = numel(notNormal);

if n_free == 0 || isempty(scan.U)
    return
end

k = size(scan.S, 1);

%% Projection U' * f

alpha = reshape( ...
    pagemtimes( ...
        scan.U, ...
        "ctranspose", ...
        f, ...
        "none"), ...
    k, ...
    n_free);

%% Apply the same singular-value support used by the inverse

active = scan.active_singular;

alpha_active = alpha;
alpha_active(~active) = 0;

%% Goodness of fit
%
% Old code:
%
%   pot = lf * mom;
%   gof = 1 - norm(f-pot)^2 / norm(f)^2;
%
% For the active SVD subspace this is exactly:
%
%   ||U_active' f||^2 / ||f||^2

gof = ...
    (sum(abs(alpha_active).^2, 1) ./ fn2).';

%% Compute source moment
%
% mom = V * S^{-1} * U' * f
%
% with pinv-style truncation when requested.

scaled = zeros( ...
    size(alpha), ...
    'like', alpha);

scaled(active) = ...
    alpha(active) ./ scan.S(active);

mom = reshape( ...
    pagemtimes( ...
        scan.V, ...
        reshape(scaled, k, 1, n_free)), ...
    k, ...
    n_free);

%% Return reduced-dimensional moment to XYZ coordinates

if scan.rank_reduce && ~isempty(scan.V_reg)

    mom3 = reshape( ...
        pagemtimes( ...
            scan.V_reg, ...
            reshape(mom, k, 1, n_free)), ...
        3, ...
        n_free);

else

    mom3 = mom;

end

%% Normalise orientation

mn = sqrt(sum(abs(mom3).^2, 1));

valid_moment = mn > 0;

mom3(:, valid_moment) = ...
    mom3(:, valid_moment) ./ ...
    mn(valid_moment);

mom3(:, ~valid_moment) = 0;

%% Store vector-valued GOF

z_vec(notNormal) = ...
    gof .* mom3(1, :).';

z_vec(notNormal + n_interp) = ...
    gof .* mom3(2, :).';

z_vec(notNormal + 2*n_interp) = ...
    gof .* mom3(3, :).';

end