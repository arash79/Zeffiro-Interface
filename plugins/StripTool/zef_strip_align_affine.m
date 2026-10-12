function zef = zef_strip_align_affine(zef)
%ZEF_STRIP_ALIGN_AFFINE  Move an implant with the head when it was placed there.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_strip_align_affine(zef)
%
%   Anatomical compartments can carry one affine that process_meshes
%   applies. A shaft embedded from the untransformed surfaces keeps an
%   identity affine, so the head moves and the shaft does not. When the
%   shaft centroid is closer to that head before the affine than after
%   it, the implant points and the shaft tip are mapped by that affine
%   once. The implant affine stays identity, so the shift is not applied
%   twice. A shaft already sitting in the transformed head is left alone.
%
%   See also zef_process_meshes, zef_strip_tool_embed.

if ~isstruct(zef) || ~isfield(zef, 'sensor_tags') || ~isfield(zef, 'compartment_tags')
    return
end
[head_tag, affine] = local_head_affine(zef);
if isempty(head_tag) || isempty(affine) || local_is_identity(affine)
    return
end
head_points = zef.([head_tag '_points']);
if isempty(head_points)
    return
end
for sensor_index = 1:numel(zef.sensor_tags)
    field_name = [zef.sensor_tags{sensor_index} '_strip_cell'];
    if ~isfield(zef, field_name) || ~iscell(zef.(field_name))
        continue
    end
    for strip_index = 1:numel(zef.(field_name))
        strip_struct = zef.(field_name){strip_index};
        if ~isstruct(strip_struct) || ~isfield(strip_struct, 'compartment_tag')
            continue
        end
        if isfield(strip_struct, 'head_frame_affine') && isequal(strip_struct.head_frame_affine, affine)
            continue
        end
        moved_strip = false;
        for part = 1:numel(strip_struct.compartment_tag)
            tag = char(string(strip_struct.compartment_tag{part}));
            [zef, moved] = local_align_tag(zef, tag, affine, head_points);
            moved_strip = moved_strip || moved;
        end
        if moved_strip
            strip_struct = local_move_strip(strip_struct, affine);
        end
        strip_struct.head_frame_affine = affine;
        zef.(field_name){strip_index} = strip_struct;
    end
end
end

function [zef, moved] = local_align_tag(zef, tag, affine, head_points)

moved = false;
point_field = [tag '_points'];
affine_field = [tag '_affine_transform'];
if isempty(tag) || ~isfield(zef, point_field) || isempty(zef.(point_field))
    return
end
if isfield(zef, affine_field) && ~local_is_identity(zef.(affine_field))
    return
end
samples = zef.(point_field);
step = max(1, floor(size(samples, 1) / 200));
samples = samples(1:step:end, :);
[~, distance_now] = knnsearch(head_points, samples);
[~, distance_shifted] = knnsearch(head_points, local_unapply(samples, affine));
if mean(distance_now) + 1 < mean(distance_shifted)
    zef.(point_field) = local_apply(zef.(point_field), affine);
    moved = true;
end
end

function strip_struct = local_move_strip(strip_struct, affine)

if isfield(strip_struct, 'tip_point') && ~isempty(strip_struct.tip_point)
    strip_struct.tip_point = local_apply(strip_struct.tip_point(:)', affine)';
end
linear = affine(1:3, 1:3);
if max(abs(linear - eye(3)), [], 'all') < 1e-8
    return
end
for field_name = {'orientation_axis', 'orientation_axis_normal', 'rotation_axis'}
    if ~isfield(strip_struct, field_name{1}) || ~iscell(strip_struct.(field_name{1}))
        continue
    end
    for index = 1:numel(strip_struct.(field_name{1}))
        strip_struct.(field_name{1}){index} = linear * strip_struct.(field_name{1}){index};
    end
end
end

function [tag, affine] = local_head_affine(zef)

tag = '';
affine = [];
if isfield(zef, 'current_sensors')
    index_field = [zef.current_sensors '_electrode_surface_index'];
    if isfield(zef, index_field)
        surface_index = zef.(index_field);
    else
        surface_index = 1;
    end
    active = {};
    for tag_index = 1:numel(zef.compartment_tags)
        candidate = zef.compartment_tags{tag_index};
        if isfield(zef, [candidate '_on']) && zef.([candidate '_on'])
            active{end + 1} = candidate; %#ok<AGROW>
        end
    end
    if ~isempty(active)
        if isfield(zef, [active{end} '_sources']) && isequal(zef.([active{end} '_sources']), -1)
            position = numel(active) - surface_index;
        else
            position = numel(active) - surface_index + 1;
        end
        position = min(max(position, 1), numel(active));
        tag = active{position};
        affine = local_matrix(zef, tag);
        if ~isempty(affine) && ~local_is_identity(affine)
            return
        end
    end
end
tag = '';
affine = [];
for tag_index = numel(zef.compartment_tags):-1:1
    candidate = zef.compartment_tags{tag_index};
    affine = local_matrix(zef, candidate);
    if ~isempty(affine) && ~local_is_identity(affine)
        tag = candidate;
        return
    end
end
end

function affine = local_matrix(zef, tag)

affine = [];
field_name = [tag '_affine_transform'];
if ~isfield(zef, field_name) || isempty(zef.(field_name))
    return
end
stored = zef.(field_name);
if iscell(stored)
    if isempty(stored)
        return
    end
    affine = stored{1};
else
    affine = stored;
end
end

function tf = local_is_identity(affine)

if iscell(affine)
    if isempty(affine)
        tf = true;
        return
    end
    affine = affine{1};
end
if isempty(affine) || ~isequal(size(affine), [4 4])
    tf = isempty(affine);
    return
end
tf = max(abs(affine - eye(4)), [], 'all') < 1e-8;
end

function point = local_unapply(point, affine)

point = double(point);
if size(point, 2) ~= 3
    point = reshape(point, 1, []);
end
hom = [point, ones(size(point, 1), 1)] / affine';
point = hom(:, 1:3);
end

function moved = local_apply(point, affine)

point = double(point);
if size(point, 2) ~= 3
    point = reshape(point, 1, []);
end
hom = [point, ones(size(point, 1), 1)] * affine';
moved = hom(:, 1:3);
end
