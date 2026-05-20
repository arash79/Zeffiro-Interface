function [f] = zef_getFilteredData(zef)
%zef_getFilteredData reads the datafrom zef.measurement and applies the
%filter that are specified in zef.inv_low_cut_frequency and
%zef.inv_low_cut_frequency at a sampling frequency of
%zef.inv_sampling_frequency.
% f has the same size as the measurement

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
