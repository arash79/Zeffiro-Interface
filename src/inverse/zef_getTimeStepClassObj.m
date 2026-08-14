function [f,t] = zef_getTimeStepClassObj(f_data, f_ind, zef, ClassObj)
%ZEF_GETTIMESTEPCLASSOBJ  Extract and average one inversion frame via CommonInverseParameters.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Class-object version of zef_getTimeStep. Uses ClassObj.time_start,
%   time_window, time_step, and sampling_frequency to select sample columns
%   for frame f_ind when inv_data_mode is "filtered_temporal". Optionally
%   averages over the interval when zef.inv_time_interval_averaging is set.
%   Always column-means f when more than one sample remains. Raw mode selects
%   f_data(:, f_ind).
%
%   [f, t] = zef_getTimeStepClassObj(f_data, f_ind, zef, ClassObj)
%
%   Inputs
%     f_data   - filtered measurements (n_channels x n_samples).
%     f_ind    - 1-based frame index.
%     zef      - session struct (base workspace if omitted).
%     ClassObj - inverse.CommonInverseParameters instance.
%
%   Outputs
%     f        - n_channels x 1 column vector after any averaging.
%     t        - sample times in seconds for the selected window (filtered mode).
%
%   See also zef_getTimeStep, zef_getFilteredDataClassObj,
%            zef_inverse_extract_bundle.

if nargin < 3
zef = evalin('base','zef');
end

data_mode = string(zef.inv_data_mode);

if data_mode == "filtered_temporal"
  
time_step = ClassObj.time_step;


sampling_freq = ClassObj.sampling_frequency;

size_Data=size(f_data,2);


if size_Data>1
    if ClassObj.time_window >=0 && ClassObj.time_start >= 0 && 1 + sampling_freq*ClassObj.time_start <= size_Data
        t_ind = max(1, 1 + floor(sampling_freq*ClassObj.time_start + sampling_freq*(f_ind - 1)*time_step)) : ...
            min(size_Data, 1 + floor(sampling_freq*(ClassObj.time_start + ClassObj.time_window)+sampling_freq*(f_ind - 1)*time_step));
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
    error("zef_getTimeStepClassObj:BadDataMode", ...
        "Unsupported zef.inv_data_mode '%s'.", char(data_mode));
    
end

if size(f,2) > 1
    f = mean(f,2);
end

end
