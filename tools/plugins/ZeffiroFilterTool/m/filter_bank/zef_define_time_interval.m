function [processed_data] = zef_define_time_interval(f, start_time, end_time, sampling_frequency)
%ZEF_DEFINE_TIME_INTERVAL  Pipeline stage: crop columns to [start_time, end_time] using sampling_frequency.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: start/end seconds and fs.
%
%Description: Define time interval
%Input: 1 Start time (s) [Default: 0], 2 End time (s) [Default: Inf],
%3 Sampling frequency (Hz) [Default: filter_sampling_rate]
%Output: Data limited to the given time interval.
%

if isstr(start_time)
    start_time = str2num(start_time);
end
if isstr(end_time)
    end_time = str2num(end_time);
end
if isstr(sampling_frequency)
    sampling_frequency = str2num(sampling_frequency);
end
%End of conversion.

length_f = size(f,2);

start_time_ind = min(max(1,1 + round(start_time*sampling_frequency)),length_f);
end_time_ind =   min(max(1,1 + round(end_time*sampling_frequency)),length_f);

processed_data = f(:,start_time_ind:end_time_ind);
