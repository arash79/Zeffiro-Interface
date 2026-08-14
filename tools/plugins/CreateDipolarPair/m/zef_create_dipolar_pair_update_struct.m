%ZEF_CREATE_DIPOLAR_PAIR_UPDATE_STRUCT  Table column 2 → zef.create_dipolar_pair_*.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. xyz, ori, strength, separation, impedance, color, length,
%   tag. Called from plot/add. Does not write sensors.
%
%   See also zef_create_dipolar_pair_update_table.

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
