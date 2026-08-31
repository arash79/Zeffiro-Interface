function [shape_param, scale_param, snr_vec] = zef_find_g_hyperprior(snr_val, tail_length_db, varargin)
%ZEF_FIND_G_HYPERPRIOR  Gamma hyperprior shape/scale from SNR (dB) and optional L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Inverse plugins (IAS, RAMUS, EXP, HBSampler, …)
%   and zef_plot_hyperprior (inv_hyperprior==2) call this. Same SNR →
%   source_strength / snr_vec path as zef_find_gaussian_prior. Then a
%   10-step search picks Gamma shape so the PDF at
%   (relative_noise_std * tail_length)^2 is near eps_val=1e-10, with
%     scale_g = relative_noise_std^2 / shape
%   so the Gamma mean is noise^2. Returned scale_param is
%     source_strength^2 * noise^2 / (n_sources * shape)
%   so Gamma(shape, scale_param) has mean equal to the Gaussian theta0.
%
%   [shape_param, scale_param, snr_vec] = zef_find_g_hyperprior(snr_val, tail_length_db)
%   [shape_param, scale_param, snr_vec] = zef_find_g_hyperprior(snr_val, tail_length_db, L, n, norm, balance, bal_param)
%
%   Inputs (after tail_length_db optional)
%     snr_val           - scalar dB, typically inv_snr - prior-over-measurement.
%     tail_length_db    - clamped to max(1, tail_length_db); tail_length = 10^(dB/20).
%     L                 - sensors × sources. Empty → no-L path (strength 1e-2).
%     source_space_size - default size(L,2) or 1.
%     normalize_data    - 'maximum' (default) or other → L2 columns.
%     balance_snr       - default 1 (true).
%     balance_param     - added to snr_val in the nested Gaussian call.
%
%   Outputs
%     shape_param  - Gamma shape (same size as snr_vec).
%     scale_param  - Gamma scale (theta0 / shape).
%     snr_vec      - per-source SNR in dB (scalar if no balance).
%
%   See also zef_find_ig_hyperprior, zef_find_gaussian_prior, zef_gamma_gpu.

L = [];

source_space_size = 1;
normalize_data = 'maximum';
eps_val = 1e-10;
delta_val = 0.1;
balance_snr = 1;
w_param = 0.5;
balance_param = 0;
tail_length_db = max(1,tail_length_db);

if length(varargin) > 0
    L = varargin{1};
    source_space_size = size(L,2);
end

if length(varargin) > 1
    source_space_size = varargin{2};
end

if length(varargin) > 2
    normalize_data = varargin{3};
end

if length(varargin) > 3
    balance_snr = varargin{4};
end

if length(varargin) > 4
    if balance_snr
        balance_param = varargin{5};
    end
end

if isempty(L)
    snr_vec = snr_val;
    snr_vec_limited = snr_vec;
    source_strength = 1e-2;
else


    if isequal(normalize_data,'maximum')

        source_strength = mean(1./((max(abs(L))').^w_param));
    else
        source_strength = mean(1./(sqrt(sum(L.^2)').^w_param));
    end



    if balance_snr
        % Same sLORETA column whitening as zef_find_gaussian_prior.
        theta0 = zef_find_gaussian_prior(snr_val+balance_param);
        std_lhood = 10^(-snr_val/20);
        S_mat = std_lhood^2*eye(size(L,1));
        d_sqrt = sqrt(theta0)*ones(size(L,2),1);
        L_inv = L.*repmat(d_sqrt',size(L,1),1);
        L_inv = d_sqrt.*(L_inv'*(inv(L_inv*L_inv' + S_mat)));
        sloreta_vec = sqrt(max(0,sum(L_inv.*L', 2)));
        L = L./sloreta_vec';
        if isequal(normalize_data,'maximum')
            signal_strength = (size(L,2)*(max(abs(L))')./sum(max(abs(L))')).^(w_param);
        else
            signal_strength = (size(L,2).*(sqrt(sum(L.^2))')./sum(sqrt(sum(L.^2))')).^(w_param);
        end
        snr_vec = snr_val + db(signal_strength);
    else
        snr_vec = snr_val;
    end

    snr_vec_limited = max(1,snr_vec);

end

relative_noise_std = 10.^(-snr_vec_limited/20);
tail_length = 10.^(tail_length_db/20);

a = zeros(size(relative_noise_std));
b = 170*ones(size(relative_noise_std));

if isgpuarray(L)
    relative_noise_std = gpuArray(relative_noise_std);
    a = gpuArray(a);
    b = gpuArray(b);
end

for j = 1 : 10

    shape_param_vec = a + (b-a).*[0:delta_val:1];

    % Gamma PDF at (noise*tail)^2 with mean = noise^2 (scale = noise^2/shape).
    p_val_vec = zef_gamma_gpu(relative_noise_std.^2.*tail_length.^2,shape_param_vec,relative_noise_std(:, ones(size(shape_param_vec,2),1)).^2 ./ (shape_param_vec));

    eps_val_aux = eps_val./(relative_noise_std.^2*tail_length.^2);

    [m_aux,i_aux] = min(abs(p_val_vec(:,2:end) - eps_val_aux), [], 2);

    i_aux = i_aux + 1;
    i_aux = min(size(p_val_vec,2),i_aux);

    b = shape_param_vec((i_aux-1)*size(p_val_vec,1)+[1:size(p_val_vec,1)]');
    a = shape_param_vec((i_aux-2)*size(p_val_vec,1)+[1:size(p_val_vec,1)]');
end

shape_param = (a+b)/2;
scale_param = source_strength.^2 .* relative_noise_std.^2 ./ (source_space_size.*shape_param);

end
