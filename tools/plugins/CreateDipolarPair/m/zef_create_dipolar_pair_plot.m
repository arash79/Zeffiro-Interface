% --- Zeffiro documentation header ---
% zef_create_dipolar_pair_update_struct; — Zef create dipolar pair update struct;.
%
% Purpose:
%   Zef create dipolar pair update struct;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.create_dipolar_pair_color (read)
%   zef.create_dipolar_pair_length (read)
%   zef.create_dipolar_pair_ori_x (read, write)
%   zef.create_dipolar_pair_ori_y (read, write)
%   zef.create_dipolar_pair_ori_z (read, write)
%   zef.create_dipolar_pair_x (read)
%   zef.create_dipolar_pair_y (read)
%   zef.create_dipolar_pair_z (read)
%   zef.h_axes1 (read)
%   zef.h_create_dipolar_pair_arrow (read, write)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_create_dipolar_pair_update_struct;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_create_dipolar_pair_update_struct;

if isfield(zef,'h_create_dipolar_pair_arrow')
    delete(zef.h_create_dipolar_pair_arrow);
end

zef.aux_field = sqrt(zef.create_dipolar_pair_ori_x.^2 + zef.create_dipolar_pair_ori_y.^2 + zef.create_dipolar_pair_ori_z.^2);
zef.create_dipolar_pair_ori_x = zef.create_dipolar_pair_ori_x/zef.aux_field;
zef.create_dipolar_pair_ori_y = zef.create_dipolar_pair_ori_y/zef.aux_field;
zef.create_dipolar_pair_ori_z = zef.create_dipolar_pair_ori_z/zef.aux_field;

hold(zef.h_axes1,'on')
zef.h_create_dipolar_pair_arrow = quiver3(zef.h_axes1,zef.create_dipolar_pair_x,...
    zef.create_dipolar_pair_y ,...
    zef.create_dipolar_pair_z ,...
    zef.create_dipolar_pair_ori_x,...
    zef.create_dipolar_pair_ori_y,...
    zef.create_dipolar_pair_ori_z,...
    5*zef.create_dipolar_pair_length,...
    'o','linewidth',3);

zef.aux_field = lines(7);
set(zef.h_create_dipolar_pair_arrow,'color',zef.aux_field(zef.create_dipolar_pair_color,:));

zef = rmfield(zef,'aux_field');
