function zef = zef_find_synthetic_source_patch_window(zef)
%ZEF_FIND_SYNTHETIC_SOURCE_PATCH_WINDOW  Open extended-source patch UI; init widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_find_synthetic_source_patch_window(zef)
%
%   Called via zef_tool_start. Runs zef_find_synthetic_source_patch_app,
%   names the figure 'ZEFFIRO Interface: Find synthetic source',
%   zef_init_fss_patch. Plot / Create synthetic data bound in the app
%   dump (update + plot_source_patch / find_source_patch).
%
%   See also zef_find_synthetic_source_patch_app,
%   zef_find_synthetic_source_patch.

zef_find_synthetic_source_patch_app;
set(zef.h_find_synthetic_source_legacy,'Name','ZEFFIRO Interface: Find synthetic source');
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_fss_patch;
uistack(flipud([zef.h_inv_synth_source_1;  zef.h_inv_synth_source_2;  zef.h_inv_synth_source_3;
    zef.h_inv_synth_source_4; zef.h_inv_synth_source_5;  zef.h_inv_synth_source_6; zef.h_inv_synth_source_7; zef.h_inv_synth_source_8;
    zef.h_inv_synth_source_9; zef.h_inv_synth_source_10;  zef.h_inv_synth_source_radius; zef.h_inv_synth_source_use_volume; zef.h_inv_synth_source_norm_ori; zef.h_inv_synth_source_plot_cones; zef.h_inv_synth_source_fix_amp;zef.h_inv_synth_source_VEP_config ]),'top');

end
