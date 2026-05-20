function [f,t] = zef_getTimeStepClassObj(f_data, f_ind, zef, ClassObj)
% --- Zeffiro documentation header ---
% zef_getTimeStepClassObj — Zef get Time Step Class Obj.
%
% Purpose:
%   Zef get Time Step Class Obj.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   f_data
%   f_ind
%   zef
%   ClassObj
%
% Outputs:
%   f
%   t
%
% Zef fields (observed):
%   zef.inv_data_mode (read)
%   zef.inv_time_interval_averaging (read)
%
% Calls (project):
%   zef_getTimeStepClassObj
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[f, t]] = zef_getTimeStepClassObj(f_data, f_ind, zef, ClassObj)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
