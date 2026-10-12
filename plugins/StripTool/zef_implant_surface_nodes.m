function nodes = zef_implant_surface_nodes(zef, selected_tag)
%ZEF_IMPLANT_SURFACE_NODES  Vertices of embedded shafts except the selected one.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   nodes = zef_implant_surface_nodes(zef, selected_tag)
%
%   Shaft and encapsulation surfaces in the same frame as zef.reuna_p.
%   The compartment named by selected_tag is omitted, so an attachment
%   aimed at that shaft is not rejected as foreign. Empty when the
%   project has no embedded strip. Does not write zef.

if nargin < 2
    selected_tag = '';
end
nodes = zeros(0, 3);
tags = local_tags(zef);
if isempty(tags)
    return
end
selected_tag = char(string(selected_tag));
for tag_index = 1:numel(tags)
    tag = tags{tag_index};
    if strcmp(tag, selected_tag)
        continue
    end
    cloud = local_cloud(zef, tag);
    if ~isempty(cloud)
        nodes = [nodes; cloud]; %#ok<AGROW>
    end
end
end

function tags = local_tags(zef)

tags = {};
if ~isstruct(zef) || ~isfield(zef, 'sensor_tags')
    return
end
for sensor_index = 1:numel(zef.sensor_tags)
    field_name = [zef.sensor_tags{sensor_index} '_strip_cell'];
    if ~isfield(zef, field_name) || ~iscell(zef.(field_name))
        continue
    end
    strip_cell = zef.(field_name);
    for strip_index = 1:numel(strip_cell)
        candidate = strip_cell{strip_index};
        if ~isstruct(candidate) || ~isfield(candidate, 'compartment_tag')
            continue
        end
        for part = 1:numel(candidate.compartment_tag)
            tag = char(string(candidate.compartment_tag{part}));
            if ~isempty(tag)
                tags{end + 1} = tag; %#ok<AGROW>
            end
        end
    end
end
tags = unique(tags, 'stable');
end

function cloud = local_cloud(zef, tag)

cloud = zeros(0, 3);
if isfield(zef, 'reuna_type') && isfield(zef, 'reuna_p')
    for surface_index = 1:size(zef.reuna_type, 1)
        if size(zef.reuna_type, 2) < 4
            break
        end
        if strcmp(char(string(zef.reuna_type{surface_index, 4})), tag)
            cloud = zef.reuna_p{surface_index};
            return
        end
    end
end
field_name = [tag '_points'];
if isfield(zef, field_name)
    cloud = zef.(field_name);
end
end
