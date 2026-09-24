function zef = zef_canonicalize_sensors(zef)
%ZEF_CANONICALIZE_SENSORS  Bring sensor sets to one internal representation.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called once from project load, after the MAT fields are on zef.
%   zef.sensors_canonical is stored with the project. A later load does
%   not migrate again.
%
%   First open of a project that lacks the flag:
%     A set that has coordinates, whose set-level visible flag is off, and
%     whose contact list is empty or entirely zero, is shown. That pair is
%     the factory default (visible starts off) plus the historical name-table
%     refresh, which wrote a zero contact list whenever the set was off.
%     It is not a per-contact choice. A set that is on, including one whose
%     contacts are all off, is left as stored. A set that is off but still
%     has at least one contact marked on is left hidden.
%     Electrode sets get names_visible on, so the figure draws the contact
%     index. The Tags checkbox still turns those labels off afterwards.
%   Coordinates, the set name, and <tag>_name_list are not rewritten.
%   Fields for a tag that is not in sensor_tags are removed.
%
%   zef = zef_canonicalize_sensors(zef)

if nargin == 0
    zef = evalin('base', 'zef');
end
if ~isstruct(zef)
    return
end
if ~isfield(zef, 'sensor_tags') || ~iscell(zef.sensor_tags)
    zef.sensor_tags = {};
end

saved_current = '';
if isfield(zef, 'current_sensors') && ~isempty(zef.current_sensors)
    saved_current = zef.current_sensors;
end

migrate = ~(isfield(zef, 'sensors_canonical') && isequal(zef.sensors_canonical, true));
zef = local_drop_orphan_sets(zef);

for i = 1:numel(zef.sensor_tags)
    tag = zef.sensor_tags{i};
    zef = zef_create_sensors(zef, tag);
    points = zef.([tag '_points']);
    n = size(points, 1);
    if n < 1
        continue
    end
    if migrate
        zef = local_migrate_visibility(zef, tag, n);
        if zef_sensor_set_is_electrodes(zef, tag)
            zef.([tag '_names_visible']) = 1;
        end
    else
        zef = local_pad_visibility(zef, tag, n);
    end
end

if ~isempty(saved_current)
    zef.current_sensors = saved_current;
end
zef.sensors_canonical = true;

if nargout == 0
    assignin('base', 'zef', zef);
end

end

function zef = local_migrate_visibility(zef, tag, n)

visible_list = local_list(zef, tag);
set_on = local_set_on(zef, tag);
has_true = ~isempty(visible_list) && any(visible_list);
if ~set_on && ~has_true
    zef.([tag '_visible']) = 1;
    zef.([tag '_visible_list']) = ones(n, 1);
elseif set_on && isempty(visible_list)
    zef.([tag '_visible_list']) = ones(n, 1);
else
    zef = local_pad_visibility(zef, tag, n);
end

end

function zef = local_pad_visibility(zef, tag, n)

visible_list = local_list(zef, tag);
if isempty(visible_list) || numel(visible_list) >= n
    if ~isempty(visible_list)
        zef.([tag '_visible_list']) = visible_list(1:min(numel(visible_list), n));
    end
    return
end
if local_set_on(zef, tag)
    pad = ones(n - numel(visible_list), 1);
else
    pad = zeros(n - numel(visible_list), 1);
end
zef.([tag '_visible_list']) = [visible_list; pad];

end

function visible_list = local_list(zef, tag)

visible_list = [];
field = [tag '_visible_list'];
if ~isfield(zef, field) || isempty(zef.(field))
    return
end
visible_list = zef.(field);
visible_list = visible_list(:);

end

function set_on = local_set_on(zef, tag)

set_on = false;
field = [tag '_visible'];
if ~isfield(zef, field) || isempty(zef.(field))
    return
end
set_on = logical(zef.(field)(1));

end

function zef = local_drop_orphan_sets(zef)

tags = zef.sensor_tags;
if isempty(tags)
    tags = {};
end
fn = fieldnames(zef);
orphan = {};
for i = 1:numel(fn)
    tok = regexp(fn{i}, '^(s\d*)_points$', 'tokens', 'once');
    if isempty(tok)
        continue
    end
    if ~any(strcmp(tok{1}, tags))
        orphan{end + 1} = tok{1}; %#ok<AGROW>
    end
end
if isempty(orphan)
    return
end
drop = false(size(fn));
for i = 1:numel(fn)
    for k = 1:numel(orphan)
        if startsWith(fn{i}, [orphan{k} '_'])
            drop(i) = true;
        end
    end
end
if any(drop)
    zef = rmfield(zef, fn(drop));
end

end
