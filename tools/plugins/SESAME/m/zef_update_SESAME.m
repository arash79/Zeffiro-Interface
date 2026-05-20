%Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.SESAME_snr=str2double(zef.SESAME_App.h_SESAME_snr — Zef.SESAME snr=str2double(zef.SESAME App.h SESAME snr.
%
% Purpose:
%   Zef.SESAME snr=str2double(zef.SESAME App.h SESAME snr.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.SESAME_App (read)
%   zef.SESAME_n_sampler (read, write)
%   zef.inv_data_segment (read, write)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read, write)
%   zef.normalize_data (read, write)
%   zef.number_of_frames (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.SESAME_snr=str2double(zef.SESAME_App.h_SESAME_snr` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef.SESAME_snr=str2double(zef.SESAME_App.h_SESAME_snr.Value);
zef.SESAME_n_sampler = str2double(zef.SESAME_App.h_SESAME_n_sampler.Value);
zef.inv_sampling_frequency = str2double(zef.SESAME_App.h_inv_sampling_frequency.Value);
zef.inv_low_cut_frequency = str2double(zef.SESAME_App.h_inv_low_cut_frequency.Value);
zef.inv_high_cut_frequency = str2double(zef.SESAME_App.h_inv_high_cut_frequency.Value);
zef.inv_time_1 = str2double(zef.SESAME_App.h_inv_time_1.Value);
zef.inv_time_2 = str2double(zef.SESAME_App.h_inv_time_2.Value);
zef.number_of_frames = str2double(zef.SESAME_App.h_number_of_frames.Value);
zef.inv_time_3 = str2double(zef.SESAME_App.h_inv_time_3.Value);
zef.inv_data_segment = str2double(zef.SESAME_App.h_inv_data_segment.Value);
zef.normalize_data = str2double(zef.SESAME_App.h_normalize_data.Value);
