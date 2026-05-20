%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if  ismac — If  ismac.
%
% Purpose:
%   If  ismac.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_exp_em_apply (read)
%   zef.h_exp_em_beta (read)
%   zef.h_exp_em_cancel (read)
%   zef.h_exp_em_data_segment (read)
%   zef.h_exp_em_high_cut_frequency (read)
%   zef.h_exp_em_low_cut_frequency (read)
%   zef.h_exp_em_map_estimation (read, write)
%   zef.h_exp_em_n_L1_iterations (read)
%   zef.h_exp_em_n_map_iterations (read)
%   zef.h_exp_em_number_of_frames (read)
%   zef.h_exp_em_sampling_frequency (read)
%   zef.h_exp_em_snr (read)
%   zef.h_exp_em_start (read)
%   zef.h_exp_em_theta0 (read)
%   … (4 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if  ismac` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if  ismac
    zef.h_exp_em_map_estimation = open('exp_em_map_estimation.fig');
elseif ispc
    zef.h_exp_em_map_estimation = open('exp_em_map_estimation.fig');
else
    zef.h_exp_em_map_estimation = open('exp_em_map_estimation.fig');
end
set(zef.h_exp_em_map_estimation,'Name','ZEFFIRO Interface: EM MAP estimation');
set(findobj(zef.h_exp_em_map_estimation.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_exp_em_map_estimation.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_exp_em;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_exp_em_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_exp_em_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_exp_em_beta ; zef.h_exp_em_theta0;
    zef.h_exp_em_snr ; zef.h_exp_em_n_map_iterations ; zef.h_exp_em_n_L1_iterations ;
    zef.h_exp_em_sampling_frequency ; zef.h_exp_em_low_cut_frequency ;
    zef.h_exp_em_high_cut_frequency ; zef.h_exp_em_time_1 ; zef.h_exp_em_time_2; zef.h_exp_em_number_of_frames; zef.h_exp_em_time_3; zef.h_exp_em_data_segment ; zef.h_exp_em_cancel ;
    zef.h_exp_em_apply; zef.h_exp_em_start  ]),'top');
