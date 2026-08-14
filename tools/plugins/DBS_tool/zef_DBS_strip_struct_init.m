%ZEF_DBS_STRIP_STRUCT_INIT  Default two-probe center_point/dir_vec onto edits.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef and strip_struct.h_center_point* /
%   h_dir_vec* handles. Defaults center_point [0 0 0; 0 0 0], dir_vec
%   [0 0 1; 0 0 1], strip_type=1, probe_num=1.
%
%   See also zef_DBS_strip_struct_update, zef_DBS_strip_struct_start.

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
