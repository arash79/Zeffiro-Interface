function strip_struct = zef_strip_from_compartment(zef, compartment_tag)
%ZEF_STRIP_FROM_COMPARTMENT  Shaft whose embedded body uses this compartment.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   strip_struct = zef_strip_from_compartment(zef, compartment_tag)
%
%   Matches compartment_tag{1} only. The encapsulation compartment is
%   not a contact surface. Empty when no sensor strip owns the tag.

strip_struct = [];
if ~isstruct(zef) || ~isfield(zef, 'sensor_tags') || isempty(compartment_tag)
    return
end
for sensor_index = 1:numel(zef.sensor_tags)
    field_name = [zef.sensor_tags{sensor_index} '_strip_cell'];
    if ~isfield(zef, field_name)
        continue
    end
    strip_cell = zef.(field_name);
    if ~iscell(strip_cell)
        continue
    end
    for strip_index = 1:numel(strip_cell)
        candidate = strip_cell{strip_index};
        if ~isstruct(candidate) || ~isfield(candidate, 'compartment_tag') || isempty(candidate.compartment_tag)
            continue
        end
        if strcmp(char(string(candidate.compartment_tag{1})), char(string(compartment_tag)))
            strip_struct = candidate;
            return
        end
    end
end
end
