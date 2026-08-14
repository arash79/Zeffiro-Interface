%ZEF_UPDATE_GAUSSIAN_PRIOR_OPTIONS  Settings → Hierarchical prior options (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ValueChangedFcn on zef.h_zef_gaussian_prior_options (wired in
%   zef_open_gaussian_prior_options). Copies h_inv_hyperprior_weight,
%   h_inv_hyperprior, tail length (dB), SNR, prior-over-measurement (dB),
%   amplitude (stored negated: zef.inv_amplitude_db =
%   -str2num(h_inv_amplitude_db.Value)), and inv_evolution_prior. Does
%   not replot; the dialog **Plot** button calls zef_plot_hyperprior.
%
%   See also zef_open_gaussian_prior_options, zef_plot_hyperprior.
zef.inv_hyperprior_weight = str2num(get(zef.h_inv_hyperprior_weight,'Value'));
zef.inv_hyperprior = get(zef.h_inv_hyperprior,'Value');
zef.inv_hyperprior_tail_length_db = str2num(get(zef.h_inv_hyperprior_tail_length_db,'Value'));
zef.inv_snr = str2num(get(zef.h_inv_snr,'Value'));
zef.inv_prior_over_measurement_db = str2num(get(zef.h_inv_prior_over_measurement_db,'Value'));
zef.inv_amplitude_db = -str2num(get(zef.h_inv_amplitude_db,'Value'));
zef.inv_evolution_prior = str2num(get(zef.h_inv_evolution_prior, 'Value'));
