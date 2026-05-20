function [f,t] = zef_getTimeStep(f_data, f_ind, zef)
% --- Zeffiro documentation header ---
% zef_getTimeStep — Zef get Time Step.
%
% Purpose:
%   Zef get Time Step.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   f_data
%   f_ind
%   zef
%
% Outputs:
%   f
%   t
%
% Zef fields (observed):
%   zef.inv_data_mode (read)
%   zef.inv_sampling_frequency (read)
%   zef.inv_time_1 (read)
%   zef.inv_time_2 (read, write)
%   zef.inv_time_3 (read)
%   zef.inv_time_interval_averaging (read)
%
% Calls (project):
%   zef_getTimeStep
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[f, t]] = zef_getTimeStep(f_data, f_ind, zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
