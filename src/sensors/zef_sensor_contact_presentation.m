function [list_names, annotations] = zef_sensor_contact_presentation(zef, tag, n)
%ZEF_SENSOR_CONTACT_PRESENTATION  List text and figure text for one sensor set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Electrode sets (EEG, EIT, TES): the Figure-tool list is "Electrode 1",
%   "Electrode 2", ... and the text drawn on the electrode is "1", "2", ...
%   Those strings are not the stored set name and not <tag>_name_list.
%   Other modalities use <tag>_name_list, or the contact index when that
%   entry is empty. The set name is never prefixed onto a contact.
%
%   [list_names, annotations] = zef_sensor_contact_presentation(zef, tag, n)
%
%   n defaults to the number of rows in <tag>_points.

list_names = {};
annotations = {};
if nargin < 2 || ~isstruct(zef) || isempty(tag)
    return
end
if nargin < 3 || isempty(n)
    n = 0;
    points_field = [tag '_points'];
    if isfield(zef, points_field)
        n = size(zef.(points_field), 1);
    end
end
n = double(n);
if n < 1
    return
end

stored = local_stored_labels(zef, tag, n);
if zef_sensor_set_is_electrodes(zef, tag)
    list_names = arrayfun(@(k) sprintf('Electrode %d', k), 1:n, 'UniformOutput', false);
    annotations = arrayfun(@(k) sprintf('%d', k), 1:n, 'UniformOutput', false);
else
    list_names = stored;
    annotations = stored;
end

end

function labels = local_stored_labels(zef, tag, n)

labels = arrayfun(@(k) sprintf('%d', k), 1:n, 'UniformOutput', false);
field = [tag '_name_list'];
if ~isfield(zef, field) || isempty(zef.(field))
    return
end
name_list = zef.(field);
for i = 1:n
    nm = '';
    if iscell(name_list) && numel(name_list) >= i && ~isempty(name_list{i})
        nm = strtrim(char(string(name_list{i})));
    elseif ~iscell(name_list) && size(name_list, 1) >= i
        try
            nm = strtrim(char(string(name_list(i, :))));
        catch
        end
    end
    if ~isempty(nm)
        labels{i} = nm;
    end
end

end
