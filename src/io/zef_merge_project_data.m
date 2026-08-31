function zef = zef_merge_project_data(zef, zef_data)
%ZEF_MERGE_PROJECT_DATA  Copy loaded project fields onto the live session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Project MAT-files may contain stale graphics handles from another
%   MATLAB session. Those must not replace the live unified-shell windows.
%   Scientific fields from zef_data overwrite zef; live figures, uicontrols,
%   and App objects are preserved.
%
%   zef = zef_merge_project_data(zef, zef_data)
%
%   See also zef_load.

if nargin < 2 || ~isstruct(zef) || ~isstruct(zef_data)
    return
end

live = struct();
fn = fieldnames(zef);
for i = 1:numel(fn)
    try
        val = zef.(fn{i});
        if local_is_live_gui(val)
            live.(fn{i}) = val;
        end
    catch
    end
end

src = fieldnames(zef_data);
for i = 1:numel(src)
    name = src{i};
    if strcmp(name, 'fieldnames')
        continue
    end
    if isfield(live, name)
        continue
    end
    % Project files must not restore GUI handles. Live h_* already sit
    % on zef; stale doubles/objects from another MATLAB session would
    % desync the redesigned shell.
    if startsWith(name, 'h_')
        continue
    end
    if ismember(name, {'save_file', 'save_file_path', 'on_screen'})
        continue
    end
    val = zef_data.(name);
    if local_is_graphics_object(val)
        continue
    end
    zef.(name) = val;
end

restore = fieldnames(live);
for i = 1:numel(restore)
    zef.(restore{i}) = live.(restore{i});
end

end

function tf = local_is_live_gui(val)

tf = false;
try
    tf = local_is_graphics_object(val) && isvalid(val);
catch
end

end

function tf = local_is_graphics_object(val)

tf = false;
if isempty(val)
    return
end
try
    if isobject(val) && (isgraphics(val) || isa(val, 'matlab.apps.AppBase') ...
            || isa(val, 'matlab.ui.Figure'))
        tf = true;
    end
catch
end

end
