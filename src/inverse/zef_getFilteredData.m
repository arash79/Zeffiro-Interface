function [f] = zef_getFilteredData(zef)
% --- Zeffiro documentation header ---
% zef_getFilteredData — Zef get Filtered Data.
%
% Purpose:
%   Zef get Filtered Data.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   zef
%
% Outputs:
%   f
%
% Zef fields (observed):
%   zef.inv_data_mode (read)
%   zef.inv_high_cut_frequency (read)
%   zef.inv_low_cut_frequency (read)
%   zef.inv_sampling_frequency (read)
%   zef.measurements (read)
%   zef.normalize_data (read)
%
% Calls (project):
%   zef_getFilteredData
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[f] = zef_getFilteredData(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if (nargin == 0)
zef = evalin('base','zef');
end 

data_mode = string(zef.inv_data_mode);

if data_mode == "filtered_temporal"

    f = eval('zef.measurements');
    
high_pass = eval(['zef.inv_low_cut_frequency']);
low_pass = eval(['zef.inv_high_cut_frequency']);
sampling_freq = eval(['zef.inv_sampling_frequency']);

if isfield(zef,'normalize_data')
switch eval('zef.normalize_data')
    case 1
        data_norm = max(abs(f(:)));
    case 2
        data_norm = max(sqrt(sum(abs(f).^2)));
    case 3
        data_norm = sum(sqrt(sum(abs(f).^2)))/size(f,2);
    otherwise
        data_norm = 1;
end


fprintf('size of f');
disp(size(f));
fprintf('ndims of f: %d\n', ndims(f));
fprintf('size of data_norm');
disp(size(data_norm));
fprintf('class of f: %s\n', class(f));
fprintf('class of data_norm: %s\n', class(data_norm));

f = f/data_norm;
end

filter_order = 3;
if size(f,2) > 1 && low_pass > 0
    [lp_f_1,lp_f_2] = ellip(filter_order,3,80,low_pass/(sampling_freq/2));
    f = filter(lp_f_1,lp_f_2,f')';
end
if size(f,2) > 1 && high_pass > 0
    [hp_f_1,hp_f_2] = ellip(filter_order,3,80,high_pass/(sampling_freq/2),'high');
    f = filter(hp_f_1,hp_f_2,f')';
end

elseif data_mode == "raw"
    
    f = eval('zef.measurements');

else
    error("zef_getFilteredData:BadDataMode", ...
        "Unsupported zef.inv_data_mode '%s'.", char(data_mode));

end

end
