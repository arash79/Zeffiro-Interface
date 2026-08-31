%ZEF_UPDATE_SESAME  SESAME_App widgets → zef.SESAME_* and zef.inv_*.
%
%   Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Apply and Start buttons. Copies snr, n_sampler, band,
%   time windows, number_of_frames, normalize_data. Does not invert.
%
%   See also SESAME_inversion, SESAME_App_run.

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
