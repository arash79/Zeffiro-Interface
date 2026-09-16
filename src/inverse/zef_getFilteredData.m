function [f] = zef_getFilteredData(zef)
%ZEF_GETFILTEREDDATA  Normalize and band-pass zef.measurements for legacy inversion.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   When zef.inv_data_mode is "filtered_temporal", copies zef.measurements,
%   divides by a scale derived from zef.normalize_data (1=max entry, 2=max
%   column norm, 3=average column norm, else 1), then applies 3rd-order
%   elliptic low-pass (inv_high_cut_frequency) and high-pass
%   (inv_low_cut_frequency) filters at inv_sampling_frequency. In "raw" mode
%   returns measurements unchanged.
%
%   f = zef_getFilteredData()
%   f = zef_getFilteredData(zef)
%
%   Input
%     zef - session struct; if omitted, loaded from base workspace.
%
%   Output
%     f   - filtered data matrix (n_channels x n_samples).
%
%   Errors when inv_data_mode is unsupported. Filter cutoff frequencies of 0
%   skip the corresponding filter stage.
%
%   See also zef_getFilteredDataClassObj, zef_getTimeStep, zef_process_inversion.

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
