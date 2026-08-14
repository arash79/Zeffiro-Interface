%ZEF_APPLY_TRANSFORM  Bake current transform layers into surface and sensor coordinates.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Mesh tool button **Apply transform** (h_pushbutton23; ButtonPushedFcn
%   "zef_apply_transform;"). Script (not a function). Mutates zef in the
%   caller, then zef_update.
%
%   The multiply is not in this file: zef_process_meshes applies each
%   stored layer t_ind = 1 : length(<tag>_scaling) in this order, using
%   the compartment centroid mean_vec as rotation origin:
%     1. Homogeneous rows [xyz 1] * affine_transform{t}'  (4×4; translation
%        in A(1:3,4)). Missing cell → eye(4). Runs only if
%        isfield(zef,'<tag>_affine_transform').
%     2. Scale: xyz ← scaling_val * xyz  (and points_inf if present).
%     3. Euler degrees about mean_vec: xy, then yz, then zx
%        (2×2 [c -s; s c], applied as (xy-mean)*R' + mean).
%     4. Translate: add x/y/z_correction.
%   Sensors (current_sensors): same affine/scale/rotate/translate on
%   columns 1:3. For imaging_method 2 or 3, direction triples in columns
%   4:6 (and 7:9 if N×6 directions) are multiplied by A(1:3,1:3)'.
%
%   This script
%     1. zef_update_transform (table → current_tag arrays).
%     2. For each _on compartment that has *_points_original_surface_mesh,
%        restore points/triangles/submesh_ind from that cache so Apply
%        does not compound a previous bake.
%     3. zef_process_meshes → zef.sensors, zef.reuna_p, zef.reuna_t.
%     4. Write sensors(:,1:3) to <current_sensors>_points; methods 2/3
%        also write directions from columns 4:6 (and 7:9 if present).
%     5. Reset that sensor set's scaling/corrections/rotations to identity
%        and affine_transform to {eye(4)}, transform_name to {'Transform 1'}.
%     6. For each _on compartment, copy reuna_p{k}/reuna_t{k} onto
%        compartment_tags{k} (k counts On compartments in tag order) and
%        reset that tag's transform chain the same way. If some earlier
%        tag is off, k does not match the loop index.
%     7. Refresh *_original_surface_mesh from the baked geometry.
%     8. rmfield temporaries; zef_update; clear zef_i, zef_k.
%
%   Duplicate name: src/forward/lead_field/zef_apply_transform.m (no
%   opening zef_update_transform, uses evalin). Mesh tool calls this name.
%
%   See also zef_process_meshes, zef_add_transform, zef_mesh_tool.

zef = zef_update_transform(zef);


for zef_i = 1 : length(zef.compartment_tags)
    if eval(['zef.' zef.compartment_tags{zef_i} '_on'])
        if eval(['isfield(zef,''' zef.compartment_tags{zef_i} '_points_original_surface_mesh'')'])
            eval(['zef.' zef.compartment_tags{zef_i} '_points' '= zef.' zef.compartment_tags{zef_i} '_points_original_surface_mesh;'])
            eval(['zef.' zef.compartment_tags{zef_i} '_triangles' '= zef.' zef.compartment_tags{zef_i} '_triangles_original_surface_mesh;'])
            eval(['zef.' zef.compartment_tags{zef_i} '_submesh_ind' '= zef.' zef.compartment_tags{zef_i} '_submesh_ind_original_surface_mesh;'])
        end
    end
end

zef = zef_process_meshes(zef);
zef.apply_transform_sensors = zef.sensors;
zef.apply_transform_reuna_p = zef.reuna_p;
zef.apply_transform_reuna_t = zef.reuna_t;

eval(['zef.' eval('zef.current_sensors') '_points = zef.apply_transform_sensors(:,1:3);']);

if ismember(eval('zef.imaging_method'),[2 3])
    eval(['zef.' eval('zef.current_sensors')  '_directions(:,1:3) = zef.apply_transform_sensors(:,4:6);']);
end

if size(eval(['zef.' eval('zef.current_sensors') '_directions']),2) == 6
    eval(['zef.' eval('zef.current_sensors') '_directions(:,4:6) = zef.apply_transform_sensors(:,7:9);']);
end

eval(['zef.' eval('zef.current_sensors') '_scaling = 1;']);
eval(['zef.' eval('zef.current_sensors') '_x_correction = 0;']);
eval(['zef.' eval('zef.current_sensors') '_y_correction = 0;']);
eval(['zef.' eval('zef.current_sensors') '_z_correction = 0;']);
eval(['zef.' eval('zef.current_sensors') '_xy_rotation = 0;']);
eval(['zef.' eval('zef.current_sensors') '_yz_rotation = 0;']);
eval(['zef.' eval('zef.current_sensors') '_zx_rotation = 0;']);
eval(['zef.' eval('zef.current_sensors') '_affine_transform = {[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]};']);


eval(['zef.' eval('zef.current_sensors') '_transform_name =  {''Transform 1''};']);

zef.apply_transform_compartment_tags = eval('zef.compartment_tags');
zef_k = 0;
for zef_i = 1 : length(zef.apply_transform_compartment_tags)

    if  eval(['zef.' zef.apply_transform_compartment_tags{zef_i} '_on'])
        zef_k = zef_k + 1;
        % zef_k is the On-compartment counter (reuna_p index), also used as the tag index.
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_points = zef.apply_transform_reuna_p{' num2str(zef_k) '};']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_triangles = zef.apply_transform_reuna_t{' num2str(zef_k) '};']);

        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_scaling = 1;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_x_correction = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_y_correction = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_z_correction = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_xy_rotation = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_yz_rotation = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_zx_rotation = 0;']);
        eval(['zef.'  zef.apply_transform_compartment_tags{zef_k} '_affine_transform = {[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]};']);
        eval(['zef.' zef.apply_transform_compartment_tags{zef_k} '_transform_name =  {''Transform 1''};']);

    end

end

for zef_i = 1 : length(zef.compartment_tags)
    if eval(['zef.' zef.compartment_tags{zef_i} '_on'])
        if eval(['isfield(zef,''' zef.compartment_tags{zef_i} '_points_original_surface_mesh'')'])
            eval(['zef.' zef.compartment_tags{zef_i} '_points_original_surface_mesh' '= zef.' zef.compartment_tags{zef_i} '_points;']);
            eval(['zef.' zef.compartment_tags{zef_i} '_triangles_original_surface_mesh' '= zef.' zef.compartment_tags{zef_i} '_triangles;']);
            eval(['zef.' zef.compartment_tags{zef_i} '_submesh_ind_original_surface_mesh' '= zef.' zef.compartment_tags{zef_i} '_submesh_ind;']);
        end
    end
end

zef = rmfield(zef,{'apply_transform_sensors','apply_transform_reuna_p','apply_transform_reuna_t','apply_transform_compartment_tags'});
zef = zef_update(zef);
clear zef_i zef_k;
