function tf = zef_strip_is_encapsulation(zef, compartment_tag)
%ZEF_STRIP_IS_ENCAPSULATION  True for the capsule around an embedded shaft.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   tf = zef_strip_is_encapsulation(zef, compartment_tag)
%
%   Encapsulation is compartment_tag{2} on the strip. The shaft body is
%   compartment_tag{1}. Does not write zef.

tf = false;
if ~isstruct(zef) || ~isfield(zef, 'sensor_tags') || isempty(compartment_tag)
    return
end
compartment_tag = char(string(compartment_tag));
for sensor_index = 1:numel(zef.sensor_tags)
    field_name = [zef.sensor_tags{sensor_index} '_strip_cell'];
    if ~isfield(zef, field_name) || ~iscell(zef.(field_name))
        continue
    end
    for strip_index = 1:numel(zef.(field_name))
        candidate = zef.(field_name){strip_index};
        if ~isstruct(candidate) || ~isfield(candidate, 'compartment_tag') || numel(candidate.compartment_tag) < 2
            continue
        end
        if strcmp(char(string(candidate.compartment_tag{2})), compartment_tag)
            tf = true;
            return
        end
    end
end
end
