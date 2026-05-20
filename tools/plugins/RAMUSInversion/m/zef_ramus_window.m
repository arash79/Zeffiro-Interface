%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_ramus_window(zef)
% --- Zeffiro documentation header ---
% zef_ramus_window — Zef ramus window.
%
% Purpose:
%   Zef ramus window.
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
%   zef.h_ramus_apply (read)
%   zef.h_ramus_cancel (read)
%   zef.h_ramus_high_cut_frequency (read)
%   zef.h_ramus_hyperprior (read)
%   zef.h_ramus_ias_map_estimation (read)
%   zef.h_ramus_init_guess_mode (read)
%   zef.h_ramus_low_cut_frequency (read)
%   zef.h_ramus_make_multires_dec (read)
%   zef.h_ramus_multires_n_iter (read)
%   zef.h_ramus_multires_n_levels (read)
%   zef.h_ramus_multires_sparsity (read)
%   zef.h_ramus_normalize_data (read)
%   zef.h_ramus_number_of_frames (read)
%   zef.h_ramus_sampling_frequency (read)
%   … (7 more)
%
% Calls (project):
%   zef_ramus_iteration
%   zef_ramus_window
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ramus_window(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
