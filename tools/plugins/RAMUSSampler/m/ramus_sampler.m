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
%   zef.h_ias_map_estimation (read, write)
%   zef.h_inv_apply (read)
%   zef.h_inv_beta (read)
%   zef.h_inv_cancel (read)
%   zef.h_inv_data_segment (read)
%   zef.h_inv_high_cut_frequency (read)
%   zef.h_inv_hyperprior (read)
%   zef.h_inv_likelihood_std (read)
%   zef.h_inv_low_cut_frequency (read)
%   zef.h_inv_multires_n_iter (read)
%   zef.h_inv_multires_n_levels (read)
%   zef.h_inv_multires_sparsity (read)
%   zef.h_inv_n_burn_in (read)
%   zef.h_inv_n_sampler (read)
%   … (8 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if  ismac` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if  ismac
    zef.h_ias_map_estimation = open('ramus_sampler.fig');
elseif ispc
    zef.h_ias_map_estimation = open('ramus_sampler.fig');
else
    zef.h_ias_map_estimation = open('ramus_sampler.fig');
end
set(zef.h_ias_map_estimation,'Name','ZEFFIRO Interface: Metropolized RAMUS Sampler');
set(findobj(zef.h_ias_map_estimation.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_ias_map_estimation.Children,'-property','FontSize'),'FontSize',zef.font_size);
zef_init_ramus_sampler;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_inv_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_inv_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_inv_multires_n_levels; zef.h_inv_multires_sparsity; zef.h_inv_hyperprior ; zef.h_inv_beta ; zef.h_inv_theta0;
    zef.h_inv_likelihood_std ; zef.h_inv_n_sampler; zef.h_inv_n_burn_in; zef.h_inv_multires_n_iter ;
    zef.h_inv_sampling_frequency ; zef.h_inv_low_cut_frequency ;
    zef.h_inv_high_cut_frequency ; zef.h_inv_time_1 ; zef.h_inv_time_2; zef.h_number_of_frames; zef.h_inv_time_3; zef.h_inv_data_segment ; zef.h_inv_cancel ;
    zef.h_inv_apply; zef.h_inv_start  ]),'top');
