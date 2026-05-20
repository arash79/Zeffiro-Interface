% --- Zeffiro documentation header ---
% if not(isfield(zef,'strip_struct')) — If not(isfield(zef,'strip struct')).
%
% Purpose:
%   If not(isfield(zef,'strip struct')).
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.strip_struct (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'strip_struct'))` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if not(isfield(zef,'strip_struct'))
zef.strip_struct = struct;
end

if not(isfield(zef.strip_struct,'center_point'))
zef.strip_struct.center_point = [0 0 0;0 0 0];
end


if not(isfield(zef.strip_struct,'dir_vec'))
zef.strip_struct.dir_vec = [0 0 1; 0 0 1];
end

if not(isfield(zef.strip_struct,'strip_type'))
zef.strip_struct.strip_type = 1;
end

if not(isfield(zef.strip_struct,'probe_num'))
zef.strip_struct.probe_num = 1;
end


zef.strip_struct.h_center_point11.String = num2str(zef.strip_struct.center_point(1,1));
zef.strip_struct.h_center_point12.String = num2str(zef.strip_struct.center_point(1,2));
zef.strip_struct.h_center_point13.String = num2str(zef.strip_struct.center_point(1,3));
zef.strip_struct.h_dir_vec11.String = num2str(zef.strip_struct.dir_vec(1,1));
zef.strip_struct.h_dir_vec12.String = num2str(zef.strip_struct.dir_vec(1,2));
zef.strip_struct.h_dir_vec13.String = num2str(zef.strip_struct.dir_vec(1,3));

zef.strip_struct.h_center_point21.String = num2str(zef.strip_struct.center_point(2,1));
zef.strip_struct.h_center_point22.String = num2str(zef.strip_struct.center_point(2,2));
zef.strip_struct.h_center_point23.String = num2str(zef.strip_struct.center_point(2,3));
zef.strip_struct.h_dir_vec21.String = num2str(zef.strip_struct.dir_vec(2,1));
zef.strip_struct.h_dir_vec22.String = num2str(zef.strip_struct.dir_vec(2,2));
zef.strip_struct.h_dir_vec23.String = num2str(zef.strip_struct.dir_vec(2,3));

zef.strip_struct.h_strip_type = zef.strip_struct.strip_type;

zef.strip_struct.h_probe_num = zef.strip_struct.probe_num;
