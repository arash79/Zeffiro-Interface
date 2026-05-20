%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_find_synthetic_source_legacy_window(zef)
% --- Zeffiro documentation header ---
% zef_find_synthetic_source_legacy_window — Zef find synthetic source legacy window.
%
% Purpose:
%   Zef find synthetic source legacy window.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_find_synthetic_source_legacy (read)
%   zef.h_inv_synth_source_1 (read)
%   zef.h_inv_synth_source_10 (read)
%   zef.h_inv_synth_source_2 (read)
%   zef.h_inv_synth_source_3 (read)
%   zef.h_inv_synth_source_4 (read)
%   zef.h_inv_synth_source_5 (read)
%   zef.h_inv_synth_source_6 (read)
%   zef.h_inv_synth_source_7 (read)
%   zef.h_inv_synth_source_8 (read)
%   zef.h_inv_synth_source_9 (read)
%
% Calls (project):
%   zef_find_synthetic_source_legacy_window
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_find_synthetic_source_legacy_window(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header



zef_find_synthetic_source_legacy_app;
set(zef.h_find_synthetic_source_legacy,'Name','ZEFFIRO Interface: Find synthetic source');
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_find_synthetic_source_legacy.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_fss_legacy;
uistack(flipud([zef.h_inv_synth_source_1;  zef.h_inv_synth_source_2;  zef.h_inv_synth_source_3;
    zef.h_inv_synth_source_4; zef.h_inv_synth_source_5;  zef.h_inv_synth_source_6; zef.h_inv_synth_source_7; zef.h_inv_synth_source_8;
    zef.h_inv_synth_source_9; zef.h_inv_synth_source_10  ]),'top');

end
