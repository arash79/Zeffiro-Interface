% --- Zeffiro documentation header ---
% zef.create_dipolar_pair_x = zef.h_create_dipolar_pair_table — Zef.create dipolar pair x = zef.h create dipolar pair table.
%
% Purpose:
%   Zef.create dipolar pair x = zef.h create dipolar pair table.
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
%   zef.create_dipolar_pair_y (read, write)
%   zef.create_dipolar_pair_z (read, write)
%   zef.h_create_dipolar_pair_table (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.create_dipolar_pair_x = zef.h_create_dipolar_pair_table` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.create_dipolar_pair_x = zef.h_create_dipolar_pair_table.Data{1,2};
zef.create_dipolar_pair_y = zef.h_create_dipolar_pair_table.Data{2,2};
zef.create_dipolar_pair_z = zef.h_create_dipolar_pair_table.Data{3,2};
zef.create_dipolar_pair_ori_x = zef.h_create_dipolar_pair_table.Data{4,2};
zef.create_dipolar_pair_ori_y = zef.h_create_dipolar_pair_table.Data{5,2};
zef.create_dipolar_pair_ori_z = zef.h_create_dipolar_pair_table.Data{6,2};
zef.create_dipolar_pair_strength = zef.h_create_dipolar_pair_table.Data{7,2};
zef.create_dipolar_pair_separation = zef.h_create_dipolar_pair_table.Data{8,2};
zef.create_dipolar_pair_impedance = zef.h_create_dipolar_pair_table.Data{9,2};
zef.create_dipolar_pair_color = zef.h_create_dipolar_pair_table.Data{10,2};
zef.create_dipolar_pair_length = zef.h_create_dipolar_pair_table.Data{11,2};
zef.create_dipolar_pair_tag = zef.h_create_dipolar_pair_table.Data{12,2};
