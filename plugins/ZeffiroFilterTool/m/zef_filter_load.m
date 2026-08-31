%ZEF_FILTER_LOAD  Load button: .mat of filter_* fields (after reset).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_load. uigetfile '*.mat' starting
%   at filter_save_file_path (or default). Loads the chosen file's
%   zef_data struct onto zef and calls zef_update_filter_tool. Cancel
%   (file==0) or a mat without zef_data is a no-op.
%
%   See also zef_filter_save_as, zef_filter_reset.

if not(isempty(zef.save_file_path)) && not(zef.save_file_path==0)
    [picked_file, picked_path] = uigetfile('*.mat','Load filter',zef.filter_save_file_path);
else
    [picked_file, picked_path] = uigetfile('*.mat','Load filter');
end
if isequal(picked_file, 0)
    return
end

loaded = load(fullfile(picked_path, picked_file));
if ~isfield(loaded, 'zef_data')
    return
end

zef_filter_reset;
zef.filter_save_file = picked_file;
zef.filter_save_file_path = picked_path;
zef_data = loaded.zef_data;
fn = fieldnames(zef_data);
for zef_i = 1:length(fn)
    zef.(fn{zef_i}) = zef_data.(fn{zef_i});
end
clear zef_i zef_data loaded fn picked_file picked_path;
zef_update_filter_tool;
