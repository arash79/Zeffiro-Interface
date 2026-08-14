%ZEF_INIT_BUTTERFLY_PLOT  Butterfly-plot defaults and widget fill (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. If bf_* fields are missing, copies from inv_sampling_frequency,
%   inv_low/high_cut_frequency, inv_time_1/2, inv_data_segment,
%   normalize_data. Then sets h_bf_* String/Value. Run from
%   zef_butterfly_plot_start after the figure exists.
%
%   See also zef_update_butterfly_plot, zef_butterfly_plot.
if not(isfield(zef,'bf_sampling_frequency'))
    zef.bf_sampling_frequency = zef.inv_sampling_frequency;
end

if not(isfield(zef,'bf_low_cut_frequency'))
    zef.bf_low_cut_frequency = zef.inv_low_cut_frequency;
end

if not(isfield(zef,'bf_high_cut_frequency'))
    zef.bf_high_cut_frequency = zef.inv_high_cut_frequency;
end

if not(isfield(zef,'bf_time_1'))
    zef.bf_time_1 = zef.inv_time_1;
end

if not(isfield(zef,'bf_time_2'))
    zef.bf_time_2 = zef.inv_time_2;
end

if not(isfield(zef,'bf_data_segment'))
    zef.bf_data_segment =  zef.inv_data_segment;
end;
if not(isfield(zef,'bf_normalize_data'))
    zef.bf_normalize_data = zef.normalize_data;
end;

set(zef.h_bf_sampling_frequency ,'string',num2str(zef.bf_sampling_frequency));
set(zef.h_bf_low_cut_frequency ,'string',num2str(zef.bf_low_cut_frequency));
set(zef.h_bf_high_cut_frequency ,'string',num2str(zef.bf_high_cut_frequency));
set(zef.h_bf_data_segment ,'string',num2str(zef.bf_data_segment));
set(zef.h_bf_normalize_data ,'value',zef.bf_normalize_data);
set(zef.h_bf_time_1 ,'string',num2str(zef.bf_time_1));
set(zef.h_bf_time_2 ,'string',num2str(zef.bf_time_2));
