%ZEF_UPDATE_BUTTERFLY_PLOT  Butterfly-plot **Plot** / **Apply** widget copy (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Copies h_bf_sampling_frequency, low/high-cut, data segment,
%   time_1/time_2, and h_bf_normalize_data into zef.bf_*. Called from the
%   **Plot** button Callback before zef_make_butterfly_plot. Does not
%   itself draw; the butterfly window is Forward tools → Butterfly plot.
%
%   See also zef_init_butterfly_plot, zef_butterfly_plot.
zef.bf_sampling_frequency = str2num(get(zef.h_bf_sampling_frequency,'string'));
zef.bf_low_cut_frequency = str2num(get(zef.h_bf_low_cut_frequency,'string'));
zef.bf_high_cut_frequency = str2num(get(zef.h_bf_high_cut_frequency,'string'));
zef.bf_data_segment = str2num(get(zef.h_bf_data_segment,'string'));
zef.bf_time_1 = str2num(get(zef.h_bf_time_1,'string'));
zef.bf_time_2 = str2num(get(zef.h_bf_time_2,'string'));
zef.bf_normalize_data = get(zef.h_bf_normalize_data ,'value');
