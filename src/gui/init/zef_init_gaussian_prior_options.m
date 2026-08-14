%ZEF_INIT_GAUSSIAN_PRIOR_OPTIONS  Defaults for Settings → Hierarchical prior options (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. isfield-guarded defaults: inv_hyperprior_tail_length_db=10,
%   inv_prior_over_measurement_db=0, inv_snr=30, inv_hyperprior=1,
%   inv_amplitude_db=20, inv_hyperprior_weight=0, inv_evolution_prior=-34.
%   Run from zef_open_gaussian_prior_options. Does not open the dialog.
%
%   See also zef_open_gaussian_prior_options.
if not(isfield(zef,'inv_hyperprior_tail_length_db'));
    zef.inv_hyperprior_tail_length_db = 10;
end;
if not(isfield(zef,'inv_prior_over_measurement_db'));
    zef.inv_prior_over_measurement_db = 0;
end;

if not(isfield(zef,'inv_snr'));
    zef.inv_snr = 30;
end;

if not(isfield(zef,'inv_hyperprior'));
    zef.inv_hyperprior = 1;
end;

if not(isfield(zef,'inv_amplitude_db'));
    zef.inv_amplitude_db = 20;
end;

if not(isfield(zef,'inv_hyperprior_weight'));
    zef.inv_hyperprior_weight = 0;
end;

if not(isfield(zef,'inv_evolution_prior'));
    zef.inv_evolution_prior = -34;
end;
