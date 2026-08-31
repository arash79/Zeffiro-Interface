function [scale_param, snr_vec] = zef_find_gaussian_prior(snr_val, varargin)
%ZEF_FIND_GAUSSIAN_PRIOR  Convert inv_snr (dB) into a Gaussian prior variance.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Inverse plugins (MNE, IAS, Kalman, …) treat sensor noise as
%   10^(-snr/20) relative to a unit signal. This helper turns that SNR
%   into the prior scale theta0 (scale_param) used as source variance:
%     scale_param = source_strength^2 * (10^(-snr/20))^2 / n_sources
%   With no lead field, source_strength is 1e-2. With L, it is the mean
%   reciprocal of column max-abs (or column L2 if normalize_data is not
%   'maximum'), raised to w_param (default 0.5).
%
%   If balance_snr is true and L is given, columns are sLORETA-whitened
%   and snr_vec is snr_val plus the dB of a per-column signal_strength
%   so poorly seen sources get a higher effective SNR. The recursive
%   call zef_find_gaussian_prior(snr_val+balance_param) has no L, so it
%   uses the 1e-2 default strength.
%
%   [scale_param, snr_vec] = zef_find_gaussian_prior(snr_val)
%   [scale_param, snr_vec] = zef_find_gaussian_prior(snr_val, L, n, norm, balance, bal_param)
%
%   Inputs (all after snr_val optional)
%     snr_val          - scalar dB, typically zef.inv_snr.
%     L                - sensors × sources lead field. Empty → no L path.
%     source_space_size- default size(L,2) or 1.
%     normalize_data   - 'maximum' (default) or other → L2 columns.
%     balance_snr      - default 1 (true).
%     balance_param    - added to snr_val in the nested prior call.
%
%   Outputs
%     scale_param  - prior variance theta0 (scalar).
%     snr_vec      - per-source SNR in dB (scalar if no balance).
%
%   See also zef_find_g_hyperprior, zef_find_ig_hyperprior.

L = [];

source_space_size = 1;
normalize_data = 'maximum';
balance_snr = 1;
w_param = 0.5;
balance_param = 0;

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

    % Per-column sLORETA-style whitening, then SNR offset from the
    % relative column strength so deep/weak sources are not under-prioritized.
    if balance_snr
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
scale_param = source_strength.^2 .* relative_noise_std.^2 ./ (source_space_size);

end
