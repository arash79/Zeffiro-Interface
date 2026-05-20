%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_open_mcmc(zef)
% --- Zeffiro documentation header ---
% zef_open_mcmc — Opens the mcmc options dialog.
%
% Purpose:
%   Opens the mcmc options dialog.
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
%   zef.h_mcmc_apply (read)
%   zef.h_mcmc_cancel (read)
%   zef.h_mcmc_cm_estimation (read)
%   zef.h_mcmc_high_cut_frequency (read)
%   zef.h_mcmc_hyperprior (read)
%   zef.h_mcmc_low_cut_frequency (read)
%   zef.h_mcmc_n_burn_in (read)
%   zef.h_mcmc_normalize_data (read)
%   zef.h_mcmc_number_of_frames (read)
%   zef.h_mcmc_sample_size (read)
%   zef.h_mcmc_sampling_frequency (read)
%   zef.h_mcmc_snr (read)
%   zef.h_mcmc_start (read)
%   zef.h_mcmc_time_1 (read)
%   … (18 more)
%
% Calls (project):
%   zef_mcmc
%   zef_mcmc_window
%   zef_open_mcmc
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_open_mcmc(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef = zef_mcmc_window(zef);

set(zef.h_mcmc_cm_estimation,'Position',[ 0.5764    0.2944    0.15    0.40]);

set(zef.h_mcmc_cm_estimation,'Name','ZEFFIRO Interface: Hierarchical Bayesian MCMC sampler');
set(findobj(zef.h_mcmc_cm_estimation.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_mcmc_cm_estimation.Children,'-property','FontSize'),'FontSize',zef.font_size);

set(zef.h_mcmc_start,'Callback','zef_update_mcmc; [zef.reconstruction, zef.reconstruction_information] = zef_mcmc(zef);');

if not(isfield(zef,'inv_hyperprior'));
    zef.inv_hyperprior = 2;
end;
if not(isfield(zef,'inv_sample_size'));
    zef.inv_sample_size = 25;
end;
if not(isfield(zef,'inv_pcg_tol'));
    zef.inv_pcg_tol = 1e-8;
end;
if not(isfield(zef,'inv_normalize_data'));
    zef.inv_normalize_data = 1;
end;
if not(isfield(zef,'inv_n_burn_in'));
    zef.inv_n_burn_in = 1;
end;

if not(isfield(zef,'ias_data_segment'));
    zef.inv_data_segment = 1;
end;

set(zef.h_mcmc_hyperprior ,'value',zef.inv_hyperprior);
set(zef.h_mcmc_n_burn_in ,'value',zef.inv_n_burn_in);
set(zef.h_mcmc_snr ,'string',num2str(zef.inv_snr));
set(zef.h_mcmc_sample_size ,'string',num2str(zef.inv_sample_size));
set(zef.h_mcmc_sampling_frequency ,'string',num2str(zef.inv_sampling_frequency));
set(zef.h_mcmc_low_cut_frequency ,'string',num2str(zef.inv_low_cut_frequency));
set(zef.h_mcmc_high_cut_frequency ,'string',num2str(zef.inv_high_cut_frequency));
set(zef.h_mcmc_normalize_data ,'value',zef.inv_normalize_data);
set(zef.h_mcmc_time_1 ,'string',num2str(zef.inv_time_1));
set(zef.h_mcmc_time_2 ,'string',num2str(zef.inv_time_2));
set(zef.h_mcmc_time_3 ,'string',num2str(zef.inv_time_3));
set(zef.h_mcmc_number_of_frames ,'string',num2str(zef.number_of_frames));

uistack(flipud([zef.h_mcmc_hyperprior ;
    zef.h_mcmc_snr ; zef.h_mcmc_sample_size ;
    zef.h_mcmc_sampling_frequency ; zef.h_mcmc_low_cut_frequency ;
    zef.h_mcmc_high_cut_frequency ; zef.h_mcmc_time_1 ; zef.h_mcmc_time_2; zef.h_mcmc_number_of_frames; zef.h_mcmc_time_3 ; zef.h_mcmc_cancel ;
    zef.h_mcmc_apply; zef.h_mcmc_start  ]),'top');

end
