%ZEF_INIT_MNE  Default mne_* fields and copy them onto the MNE widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef with h_mne_* handles from
%   zef_mne_tool_window. Defaults: mne_prior=2, mne_type=1 (MNE),
%   mne_pcg_tol=1e-8, mne_normalize_data=1, mne_data_segment=1. Copies
%   inv_snr / sampling / band / inv_time_* / number_of_frames into mne_*.
%   Does not invert (Start → zef_find_mne_reconstruction).
%
%   See also zef_update_mne, zef_mne_tool_start, zef_find_mne_reconstruction.

if not(isfield(zef,'mne_prior'));
    zef.mne_prior = 2;
end;
if not(isfield(zef,'mne_type'));
    zef.mne_type = 1;
end;
if not(isfield(zef,'mne_pcg_tol'));
    zef.mne_pcg_tol = 1e-8;
end;

zef.mne_snr = zef.inv_snr;
zef.mne_sampling_frequency = zef.inv_sampling_frequency;
zef.mne_low_cut_frequency = zef.inv_low_cut_frequency;
zef.mne_high_cut_frequency = zef.inv_high_cut_frequency;

if not(isfield(zef,'mne_normalize_data'));
    zef.mne_normalize_data = 1;
end;

zef.mne_time_1 = zef.inv_time_1;
zef.mne_time_2 = zef.inv_time_2;
zef.mne_time_3 = zef.inv_time_3;
zef.mne_number_of_frames = zef.number_of_frames;

if not(isfield(zef,'mne_data_segment'));
    zef.mne_data_segment = 1;
end;

set(zef.h_mne_prior ,'value',zef.mne_prior)
set(zef.h_mne_type ,'value',zef.mne_type);
set(zef.h_mne_sampling_frequency ,'string',num2str(zef.mne_sampling_frequency));
set(zef.h_mne_low_cut_frequency ,'string',num2str(zef.mne_low_cut_frequency));
set(zef.h_mne_high_cut_frequency ,'string',num2str(zef.mne_high_cut_frequency));
set(zef.h_mne_normalize_data ,'value',zef.mne_normalize_data);
set(zef.h_mne_time_1 ,'string',num2str(zef.mne_time_1));
set(zef.h_mne_time_2 ,'string',num2str(zef.mne_time_2));
set(zef.h_mne_time_3 ,'string',num2str(zef.mne_time_3));
set(zef.h_mne_number_of_frames ,'string',num2str(zef.mne_number_of_frames));
