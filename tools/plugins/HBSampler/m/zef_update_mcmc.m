%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.inv_hyperprior = get(zef — Zef.inv hyperprior = get(zef.
%
% Purpose:
%   Zef.inv hyperprior = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_mcmc_high_cut_frequency (read)
%   zef.h_mcmc_low_cut_frequency (read)
%   zef.h_mcmc_n_burn_in (read)
%   zef.h_mcmc_normalize_data (read)
%   zef.h_mcmc_number_of_frames (read)
%   zef.h_mcmc_sample_size (read)
%   zef.h_mcmc_sampling_frequency (read)
%   zef.h_mcmc_snr (read)
%   zef.h_mcmc_time_1 (read)
%   zef.h_mcmc_time_2 (read)
%   zef.h_mcmc_time_3 (read)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_n_burn_in (read, write)
%   zef.inv_normalize_data (read, write)
%   … (8 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.inv_hyperprior = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.inv_hyperprior = get(zef.h_mcmc_hyperprior ,'value');
zef.inv_snr = str2num(get(zef.h_mcmc_snr,'string'));
zef.inv_n_burn_in = str2num(get(zef.h_mcmc_n_burn_in,'string'));
zef.inv_sample_size = str2num(get(zef.h_mcmc_sample_size,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_mcmc_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_mcmc_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_mcmc_high_cut_frequency,'string'));
zef.inv_time_1 = str2num(get(zef.h_mcmc_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_mcmc_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_mcmc_time_3,'string'));
zef.inv_number_of_frames = str2num(get(zef.h_mcmc_number_of_frames,'string'));
zef.inv_normalize_data = get(zef.h_mcmc_normalize_data ,'value');
zef.inv_time_1 = str2num(get(zef.h_mcmc_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_mcmc_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_mcmc_time_3,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_mcmc_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_mcmc_high_cut_frequency,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_mcmc_sampling_frequency,'string'));
zef.number_of_frames = str2num(get(zef.h_mcmc_number_of_frames,'string'));
