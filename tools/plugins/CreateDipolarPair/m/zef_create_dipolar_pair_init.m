% --- Zeffiro documentation header ---
% if not(isfield(zef,'h_create_dipolar_pair_x')) — If not(isfield(zef,'h create dipolar pair x')).
%
% Purpose:
%   If not(isfield(zef,'h create dipolar pair x')).
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.create_dipolar_pair_color (read, write)
%   zef.create_dipolar_pair_impedance (read, write)
%   zef.create_dipolar_pair_length (read, write)
%   zef.create_dipolar_pair_ori_x (read, write)
%   zef.create_dipolar_pair_ori_y (read, write)
%   zef.create_dipolar_pair_ori_z (read, write)
%   zef.create_dipolar_pair_separation (read, write)
%   zef.create_dipolar_pair_strength (read, write)
%   zef.create_dipolar_pair_tag (read, write)
%   zef.create_dipolar_pair_x (read, write)
%   zef.create_dipolar_pair_y (read, write)
%   zef.create_dipolar_pair_z (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'h_create_dipolar_pair_x'))` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isfield(zef,'h_create_dipolar_pair_x'))
    zef.create_dipolar_pair_x = 0;
end

if not(isfield(zef,'h_create_dipolar_pair_y'))
    zef.create_dipolar_pair_y = 0;
end

if not(isfield(zef,'h_create_dipolar_pair_z'))
    zef.create_dipolar_pair_z = 0;
end

if not(isfield(zef,'h_create_dipolar_pair_ori_x'))
    zef.create_dipolar_pair_ori_x = 1;
end

if not(isfield(zef,'h_create_dipolar_pair_ori_y'))
    zef.create_dipolar_pair_ori_y = 0;
end

if not(isfield(zef,'h_create_dipolar_pair_ori_z'))
    zef.create_dipolar_pair_ori_z = 0;
end

if not(isfield(zef,'h_create_dipolar_pair_strength'))
    zef.create_dipolar_pair_strength = 10;
end

if not(isfield(zef,'h_create_dipolar_pair_separation'))
    zef.create_dipolar_pair_separation = 2;
end

if not(isfield(zef,'h_create_dipolar_pair_impedance'))
    zef.create_dipolar_pair_impedance = 1E3;
end

if not(isfield(zef,'h_create_dipolar_pair_color'))
    zef.create_dipolar_pair_color = 1;
end

if not(isfield(zef,'h_create_dipolar_pair_length'))
    zef.create_dipolar_pair_length = 3;
end

if not(isfield(zef,'h_create_dipolar_pair_tag'))
    zef.create_dipolar_pair_tag = 'Dipole ';
end

zef_create_dipolar_pair_update_table
