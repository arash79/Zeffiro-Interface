function zef = zef_ramus_window(zef)
%ZEF_RAMUS_WINDOW  Open RAMUS Inversion, wire Start to zef_ramus_iteration.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_ramus_window(zef)
%
%   Runs zef_ramus_app, names 'ZEFFIRO Interface: RAMUS Inversion',
%   Start → zef_update_ramus_inversion_tool; zef_ramus_iteration(zef).
%   Then zef_init_ramus_inversion_tool. Called from
%   zef_ramus_inversion_tool via zef_tool_start.
%
%   See also zef_ramus_app, zef_ramus_iteration.

zef_ramus_app;

set(zef.h_ramus_ias_map_estimation,'Position',[ 0.5764    0.2944    0.15    0.5])

set(zef.h_ramus_ias_map_estimation,'Name','ZEFFIRO Interface: RAMUS Inversion');
set(findobj(zef.h_ramus_ias_map_estimation.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_ramus_ias_map_estimation.Children,'-property','FontSize'),'FontSize',zef.font_size);

set(zef.h_ramus_start,'Callback','zef_update_ramus_inversion_tool; [zef.reconstruction, zef.reconstruction_information] = zef_ramus_iteration(zef);');

zef_init_ramus_inversion_tool;
uistack(flipud([zef.h_ramus_multires_n_levels; zef.h_ramus_multires_sparsity; zef.h_ramus_make_multires_dec; zef.h_ramus_hyperprior; zef.h_ramus_snr ; zef.h_ramus_multires_n_iter ;
    zef.h_ramus_sampling_frequency; zef.h_ramus_low_cut_frequency;
    zef.h_ramus_high_cut_frequency; zef.h_ramus_time_1 ; zef.h_ramus_time_2; zef.h_ramus_number_of_frames; zef.h_ramus_time_3; zef.h_ramus_normalize_data; zef.h_ramus_init_guess_mode; zef.h_ramus_cancel ;
    zef.h_ramus_apply; zef.h_ramus_start  ]),'top');

end
