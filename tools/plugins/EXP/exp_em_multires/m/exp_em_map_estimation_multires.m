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
%   zef.h_exp_em_map_estimation_multires (read, write)
%   zef.h_exp_em_multires_apply (read)
%   zef.h_exp_em_multires_beta (read)
%   zef.h_exp_em_multires_cancel (read)
%   zef.h_exp_em_multires_data_segment (read)
%   zef.h_exp_em_multires_high_cut_frequency (read)
%   zef.h_exp_em_multires_low_cut_frequency (read)
%   zef.h_exp_em_multires_n_L1_iterations (read)
%   zef.h_exp_em_multires_n_iter (read)
%   zef.h_exp_em_multires_n_levels (read)
%   zef.h_exp_em_multires_number_of_frames (read)
%   zef.h_exp_em_multires_q (read)
%   zef.h_exp_em_multires_sampling_frequency (read)
%   zef.h_exp_em_multires_snr (read)
%   … (7 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if  ismac` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if  ismac
    zef.h_exp_em_map_estimation_multires = open('exp_em_map_estimation_multires.fig');
elseif ispc
    zef.h_exp_em_map_estimation_multires = open('exp_em_map_estimation_multires.fig');
else
    zef.h_exp_em_map_estimation_multires = open('exp_em_map_estimation_multires.fig');
end
set(zef.h_exp_em_map_estimation_multires,'Name','ZEFFIRO Interface: EM MAP multiresolution (RAMUS) for EP');
set(findobj(zef.h_exp_em_map_estimation_multires.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_exp_em_map_estimation_multires.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_exp_em_multires;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_exp_em_multires_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_exp_em_multires_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_exp_em_multires_n_levels; zef.h_exp_em_multires_sparsity; zef.h_exp_em_multires_q ; zef.h_exp_em_multires_beta ; zef.h_exp_em_multires_theta0;
    zef.h_exp_em_multires_snr ; zef.h_exp_em_multires_n_iter ; zef.h_exp_em_multires_n_L1_iterations ;
    zef.h_exp_em_multires_sampling_frequency ; zef.h_exp_em_multires_low_cut_frequency ;
    zef.h_exp_em_multires_high_cut_frequency ; zef.h_exp_em_multires_time_1 ; zef.h_exp_em_multires_time_2; zef.h_exp_em_multires_number_of_frames; zef.h_exp_em_multires_time_3; zef.h_exp_em_multires_data_segment ; zef.h_exp_em_multires_cancel ;
    zef.h_exp_em_multires_apply; zef.h_exp_em_multires_start  ]),'top');
