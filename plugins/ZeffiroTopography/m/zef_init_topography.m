%ZEF_INIT_TOPOGRAPHY  Script: default top_* fields and push them onto widgets.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_topography after the window exists. Not a function:
%   it reads/writes caller zef and zef.h_top_* handles.
%
%   Copies inverse timing/band into topography fields so Start uses the
%   same window as Inverse tools unless the user edits the widgets:
%     top_sampling_frequency, top_low_cut_frequency, top_high_cut_frequency
%       ← inv_sampling_frequency, inv_low_cut_frequency, inv_high_cut_frequency
%     top_time_1/2/3 ← inv_time_1/2/3
%     top_number_of_frames ← number_of_frames
%   Defaults if missing: top_regularization_parameter = 5 (added in the
%   inverse-distance denominator in zef_evaluate_topography),
%   top_data_segment ← inv_data_segment, top_normalize_data = 1.
%
%   Then writes those values into the string/value widgets. Does not
%   compute top_reconstruction.
%
%   See also zef_topography, zef_update_topography, zef_evaluate_topography.
%

if not(isfield(zef,'top_regularization_parameter'));
    zef.top_regularization_parameter = 5;
end;

zef.top_sampling_frequency = zef.inv_sampling_frequency;
zef.top_low_cut_frequency = zef.inv_low_cut_frequency;
zef.top_high_cut_frequency = zef.inv_high_cut_frequency ;

if not(isfield(zef,'top_data_segment'));
    zef.top_data_segment = zef.inv_data_segment;
end;
if not(isfield(zef,'top_normalize_data'));
    zef.top_normalize_data = 1;
end;

zef.top_time_1 = zef.inv_time_1;
zef.top_time_2 = zef.inv_time_2;
zef.top_time_3 = zef.inv_time_3;
zef.top_number_of_frames = zef.number_of_frames;


set(zef.h_top_regularization_parameter ,'string',num2str(zef.top_regularization_parameter));
set(zef.h_top_sampling_frequency ,'string',num2str(zef.top_sampling_frequency));
set(zef.h_top_low_cut_frequency ,'string',num2str(zef.top_low_cut_frequency));
set(zef.h_top_high_cut_frequency ,'string',num2str(zef.top_high_cut_frequency));
set(zef.h_top_data_segment ,'string',num2str(zef.top_data_segment));
set(zef.h_top_normalize_data ,'value',zef.top_normalize_data);
set(zef.h_top_time_1 ,'string',num2str(zef.top_time_1));
set(zef.h_top_time_2 ,'string',num2str(zef.top_time_2));
set(zef.h_top_time_3 ,'string',num2str(zef.top_time_3));
set(zef.h_top_number_of_frames ,'string',num2str(zef.top_number_of_frames));
