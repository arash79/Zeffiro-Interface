%ZEF_LOAD_EPOCH_POINTS  Load epoch points .mat into zef.filter_epoch_points.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_load_epoch_points. Opens a
%   '*.mat' picker, then zef_filter_reset (clears the pipeline) and
%   loads epoch points from the chosen file. Accepts either a saved
%   filter session (`zef_data.filter_epoch_points`) or a variable named
%   filter_epoch_points. Result is a row vector. Manual epoching stages
%   in filter_bank read filter_epoch_points.
%
%   See also zef_filter_reset, zef_filter_tool.

if not(isempty(zef.save_file_path)) && not(zef.save_file_path==0)
    [picked_file, picked_path] = uigetfile('*.mat','Load epoch points',zef.filter_save_file_path);
else
    [picked_file, picked_path] = uigetfile('*.mat','Load epoch points');
end
if isequal(picked_file, 0)
    return
end

zef_filter_reset;
zef.filter_save_file = picked_file;
zef.filter_save_file_path = picked_path;
loaded = load(fullfile(picked_path, picked_file));
if isfield(loaded, 'zef_data') && isstruct(loaded.zef_data) ...
        && isfield(loaded.zef_data, 'filter_epoch_points')
    pts = loaded.zef_data.filter_epoch_points;
elseif isfield(loaded, 'filter_epoch_points')
    pts = loaded.filter_epoch_points;
else
    fn = fieldnames(loaded);
    pts = loaded.(fn{1});
end
zef.filter_epoch_points = pts(:)';
