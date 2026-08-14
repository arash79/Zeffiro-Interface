%ZEF_LOAD_EPOCH_POINTS  Load epoch points .mat into zef.filter_epoch_points.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_load_epoch_points. uigetfile
%   '*.mat' into zef_data.file / .file_path. Then zef_filter_reset
%   (clears the pipeline), then load([zef.file_path zef.file]) using
%   the project zef.file, not the dialog pick. Result is reshaped to a
%   row. As written there is no matching end for the if. Manual
%   epoching stages in filter_bank read filter_epoch_points.
%
%   See also zef_filter_reset, zef_filter_tool.

if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef_data.file zef_data.file_path] = uigetfile('*.mat','Load filter',zef.filter_save_file_path);
else
    [zef_data.file zef_data.file_path] = uigetfile('*.mat','Load filter');
end
if not(isequal(zef_data.file,0));

    zef_filter_reset;
    zef.filter_save_file = zef.file;
    zef.filter_save_file_path = zef.file_path;
    zef.filter_epoch_points = load([zef.file_path zef.file]);
    zef.filter_epoch_points = zef.filter_epoch_points(:);
    zef.filter_epoch_points = zef.filter_epoch_points';
