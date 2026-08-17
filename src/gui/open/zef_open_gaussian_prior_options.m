%ZEF_OPEN_GAUSSIAN_PRIOR_OPTIONS  Settings → **Hierarchical prior options**.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. MenuSelectedFcn of h_menu_gaussian_prior_options (then
%   zef_update). zef_init_gaussian_prior_options, instantiates
%   zef_gaussian_prior_options, ValueChangedFcn →
%   zef_update_gaussian_prior_options. Amplitude widget shows
%   -zef.inv_amplitude_db. **Plot** → zef_plot_hyperprior (cla axes1).
%   Window name 'ZEFFIRO Interface: Hierarchical prior options'.
%
%   See also zef_update_gaussian_prior_options, zef_plot_hyperprior.
zef_init_gaussian_prior_options;

zef_data = zef_gaussian_prior_options;

zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
    if find(ismember(properties(zef.(zef.fieldnames{zef_i})),'ValueChangedFcn'))
        zef.(zef.fieldnames{zef_i}).ValueChangedFcn = 'zef_update_gaussian_prior_options;';
    end
end

zef = rmfield(zef,'fieldnames');

clear zef_data;

zef.h_plot_hyperprior.ButtonPushedFcn = 'zef_plot_hyperprior';
zef.h_inv_hyperprior_weight.Value = num2str(zef.inv_hyperprior_weight);
zef.h_inv_hyperprior.ItemsData = [1:length(zef.h_inv_hyperprior.Items)];
zef.h_inv_hyperprior.Value = zef.inv_hyperprior;
zef.h_inv_hyperprior_tail_length_db.Value = num2str(zef.inv_hyperprior_tail_length_db);
zef.h_inv_snr.Value = num2str(zef.inv_snr);
zef.h_inv_prior_over_measurement_db.Value = num2str(zef.inv_prior_over_measurement_db);
zef.h_inv_amplitude_db.Value = num2str(-zef.inv_amplitude_db);
zef.h_inv_evolution_prior.Value = num2str(zef.inv_evolution_prior);

zef.h_zef_gaussian_prior_options.Name = 'ZEFFIRO Interface: Hierarchical prior options';
zef = zef_ui_tag_handles(zef);
zef_ui_ready(zef.h_zef_gaussian_prior_options);
set(zef.h_zef_gaussian_prior_options,'DeleteFcn','zef_closereq;');


clear zef_data;
