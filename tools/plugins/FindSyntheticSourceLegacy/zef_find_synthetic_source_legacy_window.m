function zef = zef_find_synthetic_source_legacy_window(zef)
%ZEF_FIND_SYNTHETIC_SOURCE_LEGACY_WINDOW  Open Find synthetic source; init widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_find_synthetic_source_legacy_window(zef)
%
%   Called via zef_tool_start. Runs the GUIDE dump
%   zef_find_synthetic_source_legacy_app, names the figure
%   'ZEFFIRO Interface: Find synthetic source', font size,
%   zef_init_fss_legacy. Plot / Create synthetic data are bound in
%   the app dump (update + plot_source_legacy / find_source_legacy).
%
%   See also zef_find_synthetic_source_legacy_app,
%   zef_find_synthetic_source_legacy.

zef_find_synthetic_source_legacy_app;
set(zef.h_find_synthetic_source_legacy,'Name','ZEFFIRO Interface: Find synthetic source');
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_fss_legacy;
uistack(flipud([zef.h_inv_synth_source_1;  zef.h_inv_synth_source_2;  zef.h_inv_synth_source_3;
    zef.h_inv_synth_source_4; zef.h_inv_synth_source_5;  zef.h_inv_synth_source_6; zef.h_inv_synth_source_7; zef.h_inv_synth_source_8;
    zef.h_inv_synth_source_9; zef.h_inv_synth_source_10  ]),'top');

end
