%ZEF_UPDATE_MNE  Widgets → zef.mne_* and zef.inv_time_* / number_of_frames.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. get() on h_mne_prior/type/normalize_data and str2num of the
%   frequency and time edits. mne_likelihood_snr = zef.inv_snr (not the
%   widget). Called from the Start callback before
%   zef_find_mne_reconstruction.
%
%   See also zef_init_mne, zef_mne_tool_start.

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
