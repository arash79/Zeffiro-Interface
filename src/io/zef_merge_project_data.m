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
%   Fields from zef_data overwrite project state. The session shell
%   (zef_session_shell_names), live figures, and h_* handles stay.
%   Every other field that the file does not contain is removed, so the
%   previous project's compartments, sensors, and stray fields do not
%   leak. Fields named <tag>_* for a compartment or sensor tag that the
%   new project does not list are removed even if the file still
%   carries them. The caller fills catalog gaps with
%   zef_fill_missing_defaults.
%
%   zef = zef_merge_project_data(zef, zef_data)
%
%   See also zef_load, zef_session_shell_names, zef_fill_missing_defaults.

if nargin < 2 || ~isstruct(zef) || ~isstruct(zef_data)
    return
end

previous_tags = local_tag_list(zef);

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

% Drop the previous project's payload before copying. The session shell
% and the live figures stay. Compartment arrays, sensor arrays, and any
% other name the new file does not mention are removed.
incoming = fieldnames(zef_data);
shell = zef_session_shell_names(zef);
kept = struct();
for i = 1:numel(fn)
    name = fn{i};
    if ismember(name, incoming) || ismember(name, shell) ...
            || isfield(live, name) || startsWith(name, 'h_')
        kept.(name) = zef.(name);
    end
end
zef = kept;

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

% A tag that belonged to the previous project and is not in this one
% must not keep its <tag>_* arrays, including values the file repeated
% without listing the tag.
retired = setdiff(previous_tags, local_tag_list(zef));
zef = local_drop_retired_tag_fields(zef, retired);

% Live handles keep the startup sensors table. The loaded fields are the
% model; the table must be rebuilt before it is allowed to edit them.
zef.sensors_table_synced = false;

end

function tags = local_tag_list(zef)

tags = {};
groups = {'compartment_tags', 'sensor_tags'};
for g = 1:numel(groups)
    name = groups{g};
    if ~isfield(zef, name) || ~iscell(zef.(name))
        continue
    end
    for k = 1:numel(zef.(name))
        item = zef.(name){k};
        if ~(ischar(item) || isstring(item))
            continue
        end
        token = char(strtrim(string(item)));
        if ~isempty(token)
            tags{end+1,1} = token; %#ok<AGROW>
        end
    end
end

end

function zef = local_drop_retired_tag_fields(zef, retired)

if isempty(retired)
    return
end
shell = zef_session_shell_names(zef);
fn = fieldnames(zef);
drop = {};
for i = 1:numel(fn)
    name = fn{i};
    if ismember(name, shell) || startsWith(name, 'h_')
        continue
    end
    for k = 1:numel(retired)
        if startsWith(name, [retired{k} '_'])
            drop{end+1} = name; %#ok<AGROW>
            break
        end
    end
end
if ~isempty(drop)
    zef = rmfield(zef, drop);
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
