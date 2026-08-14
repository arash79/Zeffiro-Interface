function [f,t] = zef_getTimeStep(f_data, f_ind, zef)
%ZEF_GETTIMESTEP  Extract one inversion frame from filtered or raw measurements.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Selects the column(s) of f_data that correspond to inversion frame f_ind.
%   In filtered_temporal mode, uses zef.inv_time_1/2/3 and inv_sampling_frequency
%   to map frame index to sample indices; optionally averages over the window
%   when zef.inv_time_interval_averaging is true. In raw mode, returns
%   f_data(:, f_ind) directly.
%
%   [f, t] = zef_getTimeStep(f_data, f_ind)
%   [f, t] = zef_getTimeStep(f_data, f_ind, zef)
%
%   Inputs
%     f_data  - measurements (n_channels x n_samples), typically from
%               zef_getFilteredData.
%     f_ind   - 1-based frame index.
%     zef     - session struct; if omitted, read from base workspace.
%
%   Outputs
%     f       - n_channels x n_window_samples (or n_channels x 1 after
%               interval averaging). Unassigned if temporal window is invalid.
%     t       - sample times in seconds (double row); empty when f_data has
%               one column or mode is raw.
%
%   Reads zef.inv_data_mode, inv_sampling_frequency, inv_time_1/2/3,
%   inv_time_interval_averaging. May set zef.inv_time_2 to 0 if missing.
%
%   Errors when zef.inv_data_mode is not "filtered_temporal" or "raw".
%
%   See also zef_getFilteredData, zef_getTimeStepClassObj,
%            zef_process_inversion.

if nargin < 3
zef = evalin('base','zef');
end

data_mode = string(zef.inv_data_mode);

if data_mode == "filtered_temporal"
  
if isfield(zef,'inv_time_3')
    time_step = eval(['zef.inv_time_3']);
else
    time_step = Inf;
end

sampling_freq = eval(['zef.inv_sampling_frequency']);

size_Data=size(f_data,2);

if not(isfield(zef,'inv_time_2'))
zef.inv_time_2 = 0;
end

if size_Data>1
    if eval(['zef.inv_time_2']) >=0 && eval(['zef.inv_time_1']) >= 0 && 1 + sampling_freq*eval(['zef.inv_time_1']) <= size_Data
        t_ind = max(1, 1 + floor(sampling_freq*eval(['zef.inv_time_1'])+sampling_freq*(f_ind - 1)*time_step)) : ...
            min(size_Data, 1 + floor(sampling_freq*(eval(['zef.inv_time_1']) + eval(['zef.inv_time_2']))+sampling_freq*(f_ind - 1)*time_step));
        f = f_data(:, t_ind);
        t = (double(t_ind)-1)./sampling_freq;
    end
else
    f=f_data;
end

if isfield(zef,'inv_time_interval_averaging')
if zef.inv_time_interval_averaging
    f = mean(f,2);
end
end

elseif data_mode == "raw"
    
   f = f_data(:,f_ind);

else
    error("zef_getTimeStep:BadDataMode", ...
        "Unsupported zef.inv_data_mode '%s'.", char(data_mode));
    
end

end
