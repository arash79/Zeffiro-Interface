function [processed_data] = zef_simple_downsampling_filter(f, downsampled_frequency, sampling_frequency)
%ZEF_SIMPLE_DOWNSAMPLING_FILTER  Pipeline stage: keep every round(fs/f_down) sample.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: downsampled and original sampling frequency. Does not anti-
%   alias.
%
%Description: Simple downsampling filter
%Input: 1 Downsampled frequency (Hz) [Default: filter_sampling_rate],
%2 Original sampling frequency (Hz) [Default: filter_sampling_rate]
%Output: Data limited to the given time interval.
%

if isstr(downsampled_frequency)
    downsampled_frequency = str2num(downsampled_frequency);
end
if isstr(sampling_frequency)
    sampling_frequency = str2num(sampling_frequency);
end
%End of conversion.

skip_param = floor(sampling_frequency/downsampled_frequency);

processed_data = f(:,1:skip_param:end);
