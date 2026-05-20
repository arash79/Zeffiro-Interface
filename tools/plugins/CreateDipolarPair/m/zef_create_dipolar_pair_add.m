% --- Zeffiro documentation header ---
% zef_create_dipolar_pair_update_struct; — Zef create dipolar pair update struct;.
%
% Purpose:
%   Zef create dipolar pair update struct;.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.create_dipolar_pair_impedance (read)
%   zef.create_dipolar_pair_ori_x (read, write)
%   zef.create_dipolar_pair_ori_y (read, write)
%   zef.create_dipolar_pair_ori_z (read, write)
%   zef.create_dipolar_pair_separation (read)
%   zef.create_dipolar_pair_strength (read)
%   zef.create_dipolar_pair_tag (read)
%   zef.create_dipolar_pair_x (read)
%   zef.create_dipolar_pair_y (read)
%   zef.create_dipolar_pair_z (read)
%   zef.current_pattern (read, write)
%   zef.current_sensors (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_create_dipolar_pair_update_struct;` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_create_dipolar_pair_update_struct;

zef.aux_field = sqrt(zef.create_dipolar_pair_ori_x.^2 + zef.create_dipolar_pair_ori_y.^2 + zef.create_dipolar_pair_ori_z.^2);
zef.create_dipolar_pair_ori_x = zef.create_dipolar_pair_ori_x/zef.aux_field;
zef.create_dipolar_pair_ori_y = zef.create_dipolar_pair_ori_y/zef.aux_field;
zef.create_dipolar_pair_ori_z = zef.create_dipolar_pair_ori_z/zef.aux_field;

zef = rmfield(zef,'aux_field');

evalin('base',['zef.' zef.current_sensors '_points = [zef.' zef.current_sensors '_points; [' num2str(zef.create_dipolar_pair_x + zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_x/2) ' ' num2str(zef.create_dipolar_pair_y + zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_y/2) ' ' num2str(zef.create_dipolar_pair_z +  zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_z/2) ' 0 0 ' num2str(zef.create_dipolar_pair_impedance) ']];' ]);
evalin('base',['zef.' zef.current_sensors '_name_list{end+1} = [''' zef.create_dipolar_pair_tag ' 1''];' ]);
evalin('base',['zef.' zef.current_sensors '_points = [zef.' zef.current_sensors '_points; [' num2str(zef.create_dipolar_pair_x - zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_x/2) ' ' num2str(zef.create_dipolar_pair_y - zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_y/2) ' ' num2str(zef.create_dipolar_pair_z - zef.create_dipolar_pair_separation*zef.create_dipolar_pair_ori_z/2) ' 0 0 ' num2str(zef.create_dipolar_pair_impedance) ']];' ]);
evalin('base',['zef.' zef.current_sensors '_name_list{end+1} = [''' zef.create_dipolar_pair_tag ' 2''];' ]);

zef.current_pattern = (1E-6)*(zef.create_dipolar_pair_strength/zef.create_dipolar_pair_separation)*[zeros(size(evalin('base',['zef.' zef.current_sensors '_points']),1)-2,1) ; -1 ; 1];
zef_create_dipolar_pair_update_table;
zef_update;
