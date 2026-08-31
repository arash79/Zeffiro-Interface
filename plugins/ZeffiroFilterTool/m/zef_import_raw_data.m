%ZEF_IMPORT_RAW_DATA  Import button: load .mat/.dat into zef.raw_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_import_data. uigetfile
%   {'*.mat','*.dat'} from save_file_path when that path is set.
%   file_type==1 (.mat): struct2cell(load(...)) then first cell.
%   Otherwise load() as numeric. Cancel (file==0) is a no-op. Does
%   not run the pipeline or write measurements.
%
%   See also zef_filter_raw_data, zef_filter_substitute_raw_data_with_measurement_data.

if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import',zef.save_file_path);
else
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import');
end
if not(isequal(zef.file,0));
    if zef.file_type == 1
        [zef.raw_data] = struct2cell(load([zef.file_path zef.file]));
        zef.raw_data = zef.raw_data{1};
    else
        [zef.raw_data] = load([zef.file_path zef.file]);
    end
end
