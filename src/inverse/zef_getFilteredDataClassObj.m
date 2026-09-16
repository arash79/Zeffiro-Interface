function [f] = zef_getFilteredDataClassObj(zef,ClassObj)
%ZEF_GETFILTEREDDATACLASSOBJ  Normalize and filter measurements using CommonInverseParameters.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Class-object counterpart to zef_getFilteredData. Normalization follows
%   ClassObj.data_normalization_method ("maximum entry", "maximum column norm",
%   "average column norm", or none). Band-pass uses ClassObj.low_cut_frequency,
%   high_cut_frequency, and sampling_frequency with the same elliptic filters
%   as the legacy path when inv_data_mode is "filtered_temporal".
%
%   f = zef_getFilteredDataClassObj(zef, ClassObj)
%
%   Inputs
%     zef      - session struct with measurements and inv_data_mode.
%     ClassObj - inverse.CommonInverseParameters (or compatible) instance.
%
%   Output
%     f        - n_channels x n_samples filtered data.
%
%   See also zef_getFilteredData, zef_getTimeStepClassObj,
%            zef_inverse_extract_bundle, inverse.CommonInverseParameters.

if (nargin == 0)
zef = evalin('base','zef');
end 

data_mode = string(zef.inv_data_mode);

if data_mode == "filtered_temporal"

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
