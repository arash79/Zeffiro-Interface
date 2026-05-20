%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.mne_prior = get(zef — Zef.mne prior = get(zef.
%
% Purpose:
%   Zef.mne prior = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_mne_high_cut_frequency (read)
%   zef.h_mne_low_cut_frequency (read)
%   zef.h_mne_normalize_data (read)
%   zef.h_mne_number_of_frames (read)
%   zef.h_mne_sampling_frequency (read)
%   zef.h_mne_time_1 (read)
%   zef.h_mne_time_2 (read)
%   zef.h_mne_time_3 (read)
%   zef.h_mne_type (read)
%   zef.inv_snr (read)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read, write)
%   zef.mne_high_cut_frequency (read, write)
%   zef.mne_likelihood_snr (read, write)
%   … (9 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.mne_prior = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.mne_prior = get(zef.h_mne_prior ,'value');
zef.mne_type = get(zef.h_mne_type ,'value');
zef.mne_likelihood_snr = zef.inv_snr;
zef.mne_sampling_frequency = str2num(get(zef.h_mne_sampling_frequency,'string'));
zef.mne_low_cut_frequency = str2num(get(zef.h_mne_low_cut_frequency,'string'));
zef.mne_high_cut_frequency = str2num(get(zef.h_mne_high_cut_frequency,'string'));
zef.mne_time_1 = str2num(get(zef.h_mne_time_1,'string'));
zef.mne_time_2 = str2num(get(zef.h_mne_time_2,'string'));
zef.mne_time_3 = str2num(get(zef.h_mne_time_3,'string'));
zef.mne_number_of_frames = str2num(get(zef.h_mne_number_of_frames,'string'));
zef.mne_normalize_data = get(zef.h_mne_normalize_data ,'value');
zef.inv_time_1 = str2num(get(zef.h_mne_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_mne_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_mne_time_3,'string'));
zef.number_of_frames = str2num(get(zef.h_mne_number_of_frames,'string'));
