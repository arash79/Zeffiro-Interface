function [f] = zef_getFilteredDataClassObj(zef,ClassObj)
% --- Zeffiro documentation header ---
% zef_getFilteredDataClassObj — Zef get Filtered Data Class Obj.
%
% Purpose:
%   Zef get Filtered Data Class Obj.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
%
% Inputs:
%   zef
%   ClassObj
%
% Outputs:
%   f
%
% Zef fields (observed):
%   zef.inv_data_mode (read)
%   zef.measurements (read)
%
% Calls (project):
%   zef_getFilteredDataClassObj
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[f] = zef_getFilteredDataClassObj(zef, ClassObj)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if (nargin == 0)
zef = evalin('base','zef');
end 

data_mode = string(zef.inv_data_mode);

if data_mode == "filtered_temporal" %what is this???

    f = eval('zef.measurements');
    
high_pass = ClassObj.low_cut_frequency;
low_pass = ClassObj.high_cut_frequency;
sampling_freq = ClassObj.sampling_frequency;

switch lower(string(ClassObj.data_normalization_method))
    case "maximum entry"
        data_norm = max(abs(f(:)));
    case "maximum column norm"
        data_norm = max(sqrt(sum(abs(f).^2)));
    case "average column norm"
        data_norm = sum(sqrt(sum(abs(f).^2)))/size(f,2);
    otherwise
        data_norm = 1;
end
f = f/data_norm;

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
    error("zef_getFilteredDataClassObj:BadDataMode", ...
        "Unsupported zef.inv_data_mode '%s'.", char(data_mode));

end

end
